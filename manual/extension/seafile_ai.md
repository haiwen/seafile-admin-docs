# Seafile AI extension

From Seafile 13 Pro, users can enable ***Seafile AI*** to support the following features:

- File tags, file and image summaries, text translation, sdoc writing assistance
- Given an image, generate its corresponding tags (including objects, weather, color, etc.)
- Detect faces in images and encode them
- Detect text in images (OCR)

## Deploy Seafile AI basic service

The Seafile AI basic service will use API calls to external large language model service (e.g., *GPT-4o-mini*) to implement file labeling, file and image summaries, text translation, and sdoc writing assistance.

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

    ```
    COMPOSE_FILE='...,seafile-ai.yml' # add seafile-ai.yml

    ENABLE_SEAFILE_AI=true
    SEAFILE_AI_LLM_TYPE=open-ai
    SEAFILE_AI_LLM_URL=<your LLM endpoint URL>
    SEAFILE_AI_LLM_KEY=<your LLM access key>
    ```

    !!! note "Deploy in a cluster"
        Please also specify `SEAFILE_AI_SERVER_URL` to the host where deploys your Seafile AI basic service in `.env`, if you deploy Seafile in a cluster.

3. Restart Seafile server:

    ```sh
    docker compose down
    docker compose up -d
    ```

