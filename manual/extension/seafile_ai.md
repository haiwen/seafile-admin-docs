# Seafile AI extension

From Seafile 13 Pro, users can enable ***Seafile AI*** to support the following features:

- File tags, file and image summaries, text translation, sdoc writing assistance
- Given an image, generate its corresponding tags (including objects, weather, color, etc.)
- Detect faces in images and encode them
- Detect text locations in images and recognize them

## Deploy Seafile AI basic service

The Seafile AI basic service will use API calls to external large language model (LLM) service to implement file labeling, file and image summaries, text translation, and sdoc writing assistance.

1. Download `seafile-ai.yml`

    ```sh
    wget https://manual.seafile.com/13.0/repo/docker/seafile-ai.yml
    ```

    !!! note "Deploy in a cluster"

        If you deploy Seafile in a cluster and would like to deploy Seafile AI, please expose port `8888` in `seafile-ai.yml`:

        ```yml
        services:
          seafile-ai:
            ...
            ports:
              - 8888:8888
        ```

        At the same time, Seafile AI should be deployed on one of the cluster nodes.

2. Modify `.env`, insert or modify the following fields:

    ```sh
    COMPOSE_FILE='...,seafile-ai.yml' # add seafile-ai.yml

    ENABLE_SEAFILE_AI=true
    SEAFILE_AI_LLM_KEY=<your OpenAI LLM access key>
    ```

    !!! note "Deploy in a cluster"
        Please also specify `SEAFILE_AI_SERVER_URL` to the host where deploys your Seafile AI basic service in `.env`, if you deploy Seafile in a cluster:

        ```sh
        SEAFILE_AI_SERVER_URL=http://<your seafile-ai server host>:8888
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

!!! success "Test and use Seafile AI"
    After you deploy Seafile AI, you will be able to wake up the AI ​​assistant by selecting a few characters in the SeaDoc document:

    ![Use Seafile AI](../images/seafile-ai.png)

    If your AI assistant cannot give the correct output, please check the relevant configuration and log files (it should in the Seafile log directory `/opt/seafile-data/seafile/logs/seafile-ai.log` by default)

!!! tip
    Since the file tagging feature requires [deploying the metadata service](./metadata-server.md) first, the file tagging feature is not enabled by default. You can enable this feature in the repo's settings after enabling extension properties (see the figure below, it will only be enabled if you have management permissions for this repo).

    ![Enable Seafile AI File tags](../images/seafile-ai-file-tags.png)

## Deploy face embedding service (Optional)

Face Embedding is used to detect and encode faces in images. Generally, we **recommend** that you deploy the service on a machine with a **GPU** (it can be deployed on a machine different from the one where Seafile AI basic services are deployed). Currently, Seafile AI face embeddings support the use of *Nvidia* (using ***CUDA***) and *AMD* (using ***ROCM***) GPUs, and CPUs only. If you plan to deploy these face embeddings in an environment using GPUs, you need to make sure your GPU is within the model range supported by the acceleration environment (such as *CUDA* or *ROCM*)

1. Download Docker compose files

    === "CUDA"

        ```sh
        wget -O face-embedding.yml https://manual.seafile.com/13.0/repo/docker/face-embedding/cuda.yml
        ```
    
    === "ROCM"

        ```sh
        wget -O face-embedding.yml https://manual.seafile.com/13.0/repo/docker/face-embedding/rocm.yml
        ```

    === "CPU"

        ```sh
        wget -O face-embedding.yml https://manual.seafile.com/13.0/repo/docker/face-embedding/cpu.yml
        ```

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

2. Modify the `.env` of the Seafile AI basic service:

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
- `/opt/face_embedding/models`: Contains the model files of the face embedding. It will automatically obtain the latest applicable models at each startup. These models are hosted by Hugging Face LFS. Of course, users also manually download their own model files before the first startup.

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
