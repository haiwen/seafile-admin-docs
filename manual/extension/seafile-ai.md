# Seafile AI extension

From Seafile 13, users can enable ***Seafile AI*** to support the following features:

!!! note "Prerequisites of Seafile AI deployment"
    To deploy Seafile AI, you have to deploy [metadata server](./metadata-server.md) extension firstly. Then you can follow this manual to deploy Seafile AI.

- File tags, file and image summaries, text translation, sdoc writing assistance
- Given an image, generate its corresponding tags (including objects, weather, color, etc.)
- Detect text in images (OCR)

!!! danger "AIGC statement in Seafile"
    With the help of large language models and algorithm development, Seafile AI supports image recognition and text generation. The generated content is **diverse** and **random**, and users need to identify the generated content. **Seafile will not be responsible for AI-generated content (AIGC)**.

    At the same time, Seafile AI supports the use of custom LLM. Different large language models will have different impacts on AIGC (including functions and performance), so **Seafile will not be responsible for the corresponding rate (i.e., tokens/s), token consumption, and generated content**. Including but not limited to

    - Basic model (including model basic algorithm)
    - Parameter quantity
    - Quantization level

    When users use their own OpenAI-compatibility-API LLM service (e.g., *LM studio*, *Ollama*) and use self-ablated or abliterated models, **Seafile will not be responsible for possible bugs** (such as infinite loops outputting the same meaningless content). At the same time, Seafile does not recommend using documents such as SeaDoc to evaluate the performance of ablated models.

## Deploy Seafile AI basic service

### Deploy Seafile AI on the host with Seafile

The Seafile AI basic service will use API calls to external large language model service to implement file labeling, file and image summaries, text translation, and sdoc writing assistance.

!!! note "Redis for AI usage statistics"
    Seafile AI uses Redis to publish model token-usage events. Redis is required when [AI usage statistics](#enable-ai-usage-statistics) are enabled.

1. Download `seafile-ai.yml`

    ```sh
    wget https://manual.seafile.com/14.0/repo/docker/seafile-ai.yml
    ```

2. Modify `.env` and add the basic Seafile AI switch:

    ```env
    COMPOSE_FILE='...,seafile-ai.yml' # add seafile-ai.yml

    ENABLE_SEAFILE_AI=true
    ```

3. Open `$SEAFILE_VOLUME/seafile/conf/seafile_ai_config.yaml` and configure the model used by Seafile AI:

    ```yaml
    global:
      LLM_MODELS:
        - type: other
          url: http://<your-llm-endpoint>
          key: <your-api-key>
          model: gpt-5.4-nano
          label: GPT-5.4 Nano
          default: false
          tier: low
          hidden: false
          disable: false
        - type: other
          url: http://<your-llm-endpoint>
          key: <your-api-key>
          model: gemini-3-flash-preview
          label: Gemini 3 Flash
          default: true
          tier: medium
          hidden: false
          disable: false
          # Optional: price per 1M tokens, used for AI usage statistics.
          price:
            input_tokens: 0.15
            output_tokens: 0.60
        - type: other
          url: http://<your-llm-endpoint>
          key: <your-api-key>
          model: deepseek-v4-pro
          label: DeepSeek V4 Pro
          default: false
          tier: high
          hidden: false
          disable: false
      # Optional: override the model tier used by individual AI features.
      AI_UTILS_TIER:
        generate_summary: low
        doc_tags: low
        translate: low
        writing_assistant: medium
        ocr: low
        image_caption: medium
        image_tags: low
        search_icons: low
        rerank: low
      # Optional: required only when vector search is enabled.
      EMBEDDING_MODEL:
        type: other
        url: http://<your-llm-endpoint>
        key: <your-api-key>
        model: text-embedding-3-small
        dimensions: 1024
    ```

    If you are using a LLM service with ***OpenAI-compatible endpoints***, you can set `type` to `other` and configure `url` accurately.

    `EMBEDDING_MODEL` is optional and is used to create embeddings for [vector search](#enable-vector-search). Its `dimensions` value must match the embedding model output. The default dimension is `1024` when `dimensions` is not a positive integer.

    If you only need one model, keep a single item in `LLM_MODELS` and set its `default` field to `true`.

    The fields are described below:

    | Field | Description |
    |----------|-------------|
    | `type` | LLM provider type. For OpenAI-compatible endpoints, use `other`. |
    | `url` | The provider API endpoint. |
    | `key` | The API key used to access the model service. |
    | `model` | Model ID used in API calls. |
    | `label` | Model name shown in the model selector in Seahub. |
    | `default` | Whether this model is the default selected model. Usually only one model should be set to `true`. |
    | `tier` | Model capability tier: `low`, `medium`, or `high`. Seafile AI selects the first valid model configured for a tier when processing an AI feature assigned to that tier. |
    | `hidden` | If `true`, the model will not be shown in Seahub's model selector. |
    | `disable` | If `true`, the model is disabled and should not be used for AI requests. |
    | `dimensions` | *(For `EMBEDDING_MODEL` only)* Output dimension size. Default is `1024`. |
    | `price` | Used for calculating AI service usage cost. Contains `input_tokens` and `output_tokens` keys representing price per 1M (1,000,000) tokens. |

    !!! note "About model selection"

        Seafile AI supports using large model providers from [LiteLLM](https://docs.litellm.ai/docs/providers) or large model services with OpenAI-compatible endpoints. Therefore, Seafile AI is compatible with most custom large model services except the default model (*gpt-4o-mini*), but in order to ensure the normal use of Seafile AI features, you need to select a **multimodal large model** (such as supporting image input and recognition)

    !!! note

        The model with `default: true` is alsoe used by general AI features such as file summary generation, writing assistant, translation, and other non-chat AI functions.

    You can use `AI_UTILS_TIER`, as shown in the preceding example, to assign a model tier to individual AI features. Each feature uses the first valid model with its configured `tier`; if no model is configured for that tier, Seafile AI uses the default model.

    The default tiers are `low` for summary generation, document tags, translation, OCR, image tags, icon search, and search-result reranking; and `medium` for writing assistance and image captions.

4. Restart Seafile server:

    ```sh
    docker compose down
    docker compose up -d
    ```

### Deploy Seafile AI on another host to Seafile

1. Download `seafile-ai.yml` and `.env`:

    ```sh
    wget https://manual.seafile.com/14.0/repo/docker/seafile-ai/seafile-ai.yml
    wget -O .env https://manual.seafile.com/14.0/repo/docker/seafile-ai/env
    ```

2. Modify `.env` on the host where Seafile AI will be deployed. The environment variables used by `seafile-ai.yml` are described below. Variables with a default value can be omitted unless you need to override the default.

    Service and connection settings:

    | Variable | Description |
    |----------|-------------|
    | `SEAFILE_AI_IMAGE` | Seafile AI image. Default is `seafileltd/seafile-ai:14.0-latest`. |
    | `SEAFILE_VOLUME` | Seafile data directory mounted at `/shared` in the container. Default is `/opt/seafile-data`. |
    | `INNER_SEAHUB_SERVICE_URL` | URL used by Seafile AI to access Seahub, for example `http://<your Seafile server intranet IP>`. This variable is required for a standalone deployment. |
    | `INNER_METADATA_SERVER_URL` | URL used by Seafile AI to access the metadata server, for example `http://<your metadata server intranet IP>:8084`. |
    | `SEASEARCH_URL` | URL used by Seafile AI to access SeaSearch, for example `http://<your SeaSearch server intranet IP>:4080`. Required for AI Chat document search and vector search when Seafile AI is deployed separately. |
    | `SEASEARCH_TOKEN` | SeaSearch API authorization token. It is the Base64 encoding of the SeaSearch administrator's `username:password`. Required together with `SEASEARCH_URL`. |
    | `JWT_PRIVATE_KEY` | JWT key shared with the Seafile server and related extension services. This variable is required. |
    | `SEAFILE_AI_LOG_LEVEL` | Seafile AI log level. Default is `info`. |

    AI model settings:

    | Variable | Description |
    |----------|-------------|
    | None | Seafile AI models are configured in `seafile_ai_config.yaml`. |

    Database and cache settings:

    | Variable | Description |
    |----------|-------------|
    | `SEAFILE_MYSQL_DB_HOST` | Seafile database host. Default is `db`. |
    | `SEAFILE_MYSQL_DB_PORT` | Seafile database port. Default is `3306`. |
    | `SEAFILE_MYSQL_DB_USER` | Seafile database user. Default is `seafile`. |
    | `SEAFILE_MYSQL_DB_PASSWORD` | Seafile database password. This variable is required. |
    | `SEAFILE_MYSQL_DB_CCNET_DB_NAME` | CCNet database name. Default is `ccnet_db`. |
    | `SEAFILE_MYSQL_DB_SEAFILE_DB_NAME` | Seafile database name. Default is `seafile_db`. |
    | `SEAFILE_MYSQL_DB_SEAHUB_DB_NAME` | Seahub database name. Default is `seahub_db`. |
    | `REDIS_HOST` | Redis server host used to publish AI usage events. Default is `redis`. |
    | `REDIS_PORT` | Redis server port. Default is `6379`. |
    | `REDIS_PASSWORD` | Redis server password. Leave it empty if authentication is disabled. |

    Storage settings:

    | Variable | Description |
    |----------|-------------|
    | `SEAF_SERVER_STORAGE_TYPE` | Storage type used by the Seafile server. Use the same value as in the Seafile server configuration. |
    | `S3_COMMIT_BUCKET` | S3 bucket that stores commit objects. |
    | `S3_FS_BUCKET` | S3 bucket that stores file-system objects. |
    | `S3_BLOCK_BUCKET` | S3 bucket that stores block objects. |
    | `S3_KEY_ID` | S3 access key ID. |
    | `S3_SECRET_KEY` | S3 secret access key. |
    | `S3_USE_V4_SIGNATURE` | Whether to use AWS Signature Version 4. Default is `true`. |
    | `S3_AWS_REGION` | S3 region. Default is `us-east-1`. |
    | `S3_HOST` | S3-compatible service endpoint. Leave it empty when using the default AWS endpoint. |
    | `S3_USE_HTTPS` | Whether to use HTTPS to access S3. Default is `true`. |
    | `S3_PATH_STYLE_REQUEST` | Whether to use path-style S3 requests. Default is `false`. |
    | `S3_SSE_C_KEY` | Optional customer-provided key for S3 server-side encryption (SSE-C). |

3. Create or modify `seafile_ai_config.yaml` on both the Seafile AI host and the Seafile host with the same configuration as above. This includes `LLM_MODELS`, `AI_UTILS_TIER`, and `EMBEDDING_MODEL` when vector search is enabled.

    Seahub reads this file on the Seafile host to display the available model list, while the Seafile AI service reads its local copy on the Seafile AI host to process actual AI requests. When Seafile and Seafile AI are deployed on separate machines, the two files should stay consistent.

    The fields in `LLM_MODELS` have the same meanings as described in the deployment steps above.

    If you only need one model, keep a single item in `LLM_MODELS` and set its `default` field to `true`.

    The model with `default: true` is also used by general AI features such as file summary generation, writing assistant, translation, and other non-chat AI functions.

    Then start your Seafile AI server:

    ```sh
    docker compose up -d
    ```

4. Modify `.env` on the Seafile host:

    ```env
    SEAFILE_AI_SERVER_URL=http://<your seafile ai host>:8888
    ```

5. Restart your Seafile server:

    ```sh
    docker compose down && docker compose up -d
    ```

## Advanced operations

### Enable AI usage statistics

Seafile supports counting users' AI usage (how many tokens are used) and setting monthly AI quotas for users.

Seafile AI uses Redis to publish model token-usage events. Seafevents consumes these events and stores the aggregated usage statistics in the Seafile database. Therefore, Redis must be configured for AI usage statistics.

1. Seafile AI model prices are configured via `price` field in `seafile_ai_config.yaml`. For example:

    ```yaml
    global:
      LLM_MODELS:
        - type: openai
          model: gpt-4o-mini
          key: <your-api-key>
          price:
            input_tokens: 0.15   # input price per 1M (1,000,000) tokens
            output_tokens: 0.60  # output price per 1M tokens
    ```

2. Refer management of [roles and permission](../config/roles_permissions.md) to specify `monthly_ai_credit_per_user` (`-1` is unlimited), and the unit should be the same as in `AI_PRICES`.

    !!! note "`monthly_ai_credit_per_user` for organization user"
        For organizational team users, `monthly_ai_credit_per_user` will apply to the entire team. For example, when `monthly_ai_credit_per_user` is set to `2` (unit of doller for example) and there are 10 members in the team, all members in the team will share the quota of $2\times10=20\$$.

### Enable AI chat


Open `$SEAFILE_VOLUME/seafile/conf/seahub_settings.py` and enable AI chat:

```py
ENABLE_AI_CHAT = True
```

After this option is enabled, Seahub will display the AI chat entry for users.

Users can use the chat feature in libraries to search for files in the current library, ask questions about specific files, and generate summaries for specific files.

### Enable vector search

Vector search lets AI Chat find documents by the meaning of their AI-generated summaries. AI Chat combines vector search results with normal SeaSearch keyword search results.

Before enabling vector search, make sure that all of the following are available:

- Metadata server is deployed and metadata management is enabled for the library.
- Seafile AI is enabled and has a valid `EMBEDDING_MODEL` in `seafile_ai_config.yaml`. The embedding model must return vectors with the configured `dimensions` value.
- SeaSearch is enabled in `seafevents.conf` and its deployment supports vector indexes.
- Seafile AI can access the same SeaSearch service by using `SEASEARCH_URL` and `SEASEARCH_TOKEN`.

Configure SeaSearch in `$SEAFILE_VOLUME/seafile/conf/seafevents.conf` if it is not already configured. For deployment and configuration details, refer to [SeaSearch configuration (Pro)](../setup/use_seasearch.md).

```ini
[SEASEARCH]
enabled = true
seasearch_url = http://seasearch:4080
seasearch_token = <your SeaSearch authorization token>
```

For a standalone Seafile AI deployment, add the same SeaSearch URL and token to its `.env` file:

```env
SEASEARCH_URL=http://<your SeaSearch server host>:4080
SEASEARCH_TOKEN=<your SeaSearch authorization token>
```

Then, in the library's **Settings**, enable **Extended properties** and enable **AI chat and search**. Seafile generates summaries and creates a vector index asynchronously for supported files: sdoc, markdown, docx, pdf, and pptx. Initial indexing may take time depending on the number and size of files.

When files are added or changed, their summaries and vector index entries are updated asynchronously. Disabling AI Summary deletes the library's vector index. Check `ai_summary.log` and `seasearch_index.log` if summaries or search results are unavailable.

!!! note
    Vector search enhances AI Chat document retrieval; it does not replace normal SeaSearch keyword search. If vector search is unavailable, AI Chat continues to use keyword search.
