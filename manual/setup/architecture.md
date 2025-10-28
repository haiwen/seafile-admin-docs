# Architecture

Seafile Docker and other components are built using x86 architecture. Starting from version 13.0, we started to support the ARM architecture.

## Support status

| Component | x86 | ARM |
| -------- | --- | --- |
| seafile-mc | √ | √ |
| seafile-pro-mc | √ | √ |
| sdoc-server | √ | √ |
| notification-server | √ | √ |
| seafile-md-server | √ | Coming soon |
| seafile-ai | √ | Coming soon |
| thumbnail-server | √ | Coming soon |
| seaseach-nomkl | √ | √ |
| seasearch | √ | X |
| face-embedding | √ | X |
| index-server  | √ | X |
| office-preview | √ | X |

## Pull the ARM image

You can use the X.0-latest tag to pull the ARM image without specifying the arm tag.

```bash
docker pull seafileltd/seafile-mc:13.0-latest
```
