# Seafile AI extension

From Seafile 13, users can enable ***Seafile AI*** to support the following features:

- File tags, file and image summaries, text translation, sdoc writing assistance
- Given an image, generate its corresponding tags (including objects, weather, color, etc.)
- Detect faces in images and encode them
- Detect text in images (OCR)

## Deploy Seafile AI basic service

### Deploy Seafile AI on the host with Seafile

The Seafile AI basic service will use API calls to external large language model service to implement file labeling, file and image summaries, text translation, and sdoc writing assistance.

!!! warning "Seafile AI requires Redis cache"
    In order to deploy Seafile AI correctly, you have to use ***Redis*** as the cache. Please set `CACHE_PROVIDER=redis` in `.env` and set Redis related configuration information correctly.

1. Download `seafile-ai.yml`

    ```sh
    wget https://manual.seafile.com/13.0/repo/docker/seafile-ai.yml
    ```

2. Modify `.env`, insert or modify the following fields:

    ```
    COMPOSE_FILE='...,seafile-ai.yml' # add seafile-ai.yml

    ENABLE_SEAFILE_AI=true
    SEAFILE_AI_LLM_KEY=<your LLM access key>
    ```
    
    !!! tip "About LLM configs"
        By default, Seafile uses the ***GPT-4o-mini*** model from *OpenAI*. You only need to provide your ***OpenAI API Key***. If you need to use other LLM (including self-deployed LLM service), you also need to specify the following in `.env`:

        ```sh
        SEAFILE_AI_LLM_TYPE=<your LLM type>
        SEAFILE_AI_LLM_URL=<your LLM endpoint>
        SEAFILE_AI_LLM_KEY=<your LLM API key>
        ```

3. Restart Seafile server:

    ```sh
    docker compose down
    docker compose up -d
    ```

### Deploy Seafile AI on another host to Seafile

1. Download `seafile-ai.yml` and `.env`:

    ```sh
    wget https://manual.seafile.com/13.0/repo/docker/seafile-ai/seafile-ai.yml
    wget -O .env https://manual.seafile.com/13.0/repo/docker/seafile-ai/env
    ```

2. Modify `.env` in the host will deploy Seafile AI according to following table

    | variable               | description                                                                                                   |  
    |------------------------|---------------------------------------------------------------------------------------------------------------|  
    | `SEAFILE_VOLUME`        | The volume directory of thumbnail server data                                                                            | 
    | `JWT_PRIVATE_KEY`      | JWT key, the same as the config in Seafile `.env` file                                                         |
    | `INNER_SEAHUB_SERVICE_URL`| Inner Seafile url  |  
    | `REDIS_HOST`       | Redis server host | 
    | `REDIS_PORT`       | Redis server port | 
    | `REDIS_PASSWORD`       | Redis server password | 
    | `SEAFILE_AI_LLM_TYPE`       | Large Language Model (LLM) API Type (e.g., `openai`) | 
    | `SEAFILE_AI_LLM_URL`       | LLM API url (leave blank if you would like to use official OpenAI's API endpoint) | 
    | `SEAFILE_AI_LLM_KEY`       | LLM API key | 
    | `FACE_EMBEDDING_SERVICE_URL`       | Face embedding service url |

    then start your Seafile AI server:

    ```sh
    docker compose up -d
    ```

3. Modify `.env` in the host deployed Seafile

    ```env
    SEAFILE_AI_SERVER_URL=http://<your seafile ai host>:8888
    ```

    then restart your Seafile server

    ```sh
    docker compose down && docker compose up -d
    ```

## Deploy face embedding service (Optional)

The face embedding service is used to detect and encode faces in images and is an extension component of Seafile AI. Generally, we **recommend** that you deploy the service on a machine with a **GPU** and a graphics card driver that supports [OnnxRuntime](https://onnxruntime.ai/docs/) (so it can also be deployed on a different machine from the Seafile AI base service). Currently, the Seafile AI face embedding service only supports the following modes:

- *Nvidia* GPU, which will use the ***CUDA 12.4*** acceleration environment (at least the minimum Nvidia Geforce 531.18 driver) and requires the installation of the [Nvidia container toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html).
<!-- - *AMD* GPU, which will use the ***ROCm 6.4.1*** acceleration environment.-->
- Pure *CPU* mode

If you plan to deploy these face embeddings in an environment using a GPU, you need to make sure your graphics card is **in the range supported by the acceleration environment** (e.g., CUDA 12.4 is supported) and **correctly mapped in `/dev/dri` directory**. So in some case, the cloud servers and [WSL](https://learn.microsoft.com/en-us/windows/wsl/install) under some driver versions may not be supported.

1. Download Docker compose files

    === "CUDA"

        ```sh
        wget -O face-embedding.yml https://manual.seafile.com/13.0/repo/docker/face-embedding/cuda.yml
        ```
    === "CPU"

        ```sh
        wget -O face-embedding.yml https://manual.seafile.com/13.0/repo/docker/face-embedding/cpu.yml
        ```
    
<!--
    === "ROCM"

        ```sh
        wget -O face-embedding.yml https://manual.seafile.com/13.0/repo/docker/face-embedding/rocm.yml
        ```
-->

2. Modify `.env`, insert or modify the following fields:

    ```
    COMPOSE_FILE='...,face-embedding.yml' # add face-embedding.yml

    FACE_EMBEDDING_VOLUME=/opt/face_embedding
    ```

3. Restart Seafile server

    ```sh
    docker compose down
    docker compose up -d
    ```

4. Enable face recognition in the repo's settings:

    ![Enable face recognition](../images/face-embedding.png)

### Deploy the face embedding service on a different machine than the Seafile AI basic service

Since the face embedding service may need to be deployed on some hosts with GPU(s), it may not be deployed together with the Seafile AI basic service. At this time, you should make some changes to the Docker compose file so that the service can be accessed normally.

1. Modify `.yml` file, delete the commented out lines to expose the service port:

    ```yml
    services:
        face-embedding:
        ...
        ports:
            - 8886:8886
    ```

2. Modify the `.env` of where deployed Seafile AI:

    ```
    FACE_EMBEDDING_SERVICE_URL=http://<your face embedding service host>:8886
    ```

3. Make sure `JWT_PRIVATE_KEY` has set in the `.env` for face embedding and is same as the Seafile server

4. Restart Seafile server

    ```sh
    docker compose down
    docker compose up -d
    ```

### Persistent volume and model management

By default, the persistent volume is `/opt/face_embedding`. It will consist of two subdirectories:

- `/opt/face_embedding/logs`: Contains the startup log and access log of the face embedding
- `/opt/face_embedding/models`: Contains the model files of the face embedding. It will automatically obtain the latest applicable models at each startup. These models are hosted by [our Hugging Face repository](https://huggingface.co/Seafile/face-embedding). Of course, you can also manually download your own models on this directory (**If you fail to automatically pull the model, you can also manually download it**).

### Customizing model serving access keys

By default, the access key used by the face embedding is the same as that used by the Seafile server, which is `JWT_PRIVATE_KEY`. At some point, this will have to be modified for security reasons. If you need to customize the access key for the face embedding, you can do the following steps:

1. Modify `.env` file for both face embedding and Seafile AI:

    ```
    FACE_EMBEDDING_SERVICE_KEY=<your customizing access keys>
    ```
    
2. Restart Seafile server

    ```sh
    docker compose down
    docker compose up -d
    ```
