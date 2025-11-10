# Architecture

Seafile Docker and its components are support both x86 and ARM64 architecture. You can find detailes below.

## Support status

| Component | x86 | ARM |
| -------- | --- | --- |
| seafile-mc | √ | √ |
| seafile-pro-mc | √ | √ |
| sdoc-server | √ | √ |
| notification-server | √ | √ |
| seafile-md-server | √ | √ |
| seafile-ai | √ | √ |
| thumbnail-server | √ | √ |
| seasearch | √ | √ |
| face-embedding | √ | X |
| index-server (distributed indexing) | √ | X |

Note, for SeaSearch, you should use seaseach-nomkl version to work on ARM architecture.



## Pull the ARM image

You can use the X.0-latest tag to pull the ARM image without specifying the arm tag.

```bash
docker pull seafileltd/seafile-mc:13.0-latest
```
