# ioBroker Docker Image

<img src="https://github.com/Marc-Berg/ioBroker.docker/raw/HEAD/docs/img/iobroker_logo.png" width="400" title="ioBroker Logo">

[![Version](https://img.shields.io/github/v/tag/Marc-Berg/ioBroker.docker?sort=semver&label=version)](https://github.com/Marc-Berg/ioBroker.docker/tags)
[![Docker Pulls](https://img.shields.io/docker/pulls/marcberg/iobroker?style=flat)](https://hub.docker.com/r/marcberg/iobroker)
[![Arch](https://img.shields.io/badge/arch-amd64%20%7C%20arm64-blue)](https://hub.docker.com/r/marcberg/iobroker)
[![License](https://img.shields.io/github/license/Marc-Berg/ioBroker.docker?style=flat)](LICENSE.md)

Docker image for [ioBroker](https://www.iobroker.net), based on `node:24-trixie-slim` (Debian 13).

## Quick start

```
docker run -d --name iobroker -h iobroker -p 8081:8081 -v iobrokerdata:/opt/iobroker marcberg/iobroker
```

Admin UI: http://localhost:8081

Tags, environment variables and further usage: [Docker Hub README](docs/README_docker_hub_marcberg.md).

## Images

* [Docker Hub](https://hub.docker.com/r/marcberg/iobroker)
* [GitHub Container Registry](https://github.com/Marc-Berg/ioBroker.docker/pkgs/container/iobroker)

Use the `latest-v[major]` tag for production instead of `latest`.

## Help

* Questions: [Discussions](https://github.com/Marc-Berg/ioBroker.docker/discussions) or the [ioBroker forum](https://forum.iobroker.net/)
* Bugs and feature requests: [Issues](https://github.com/Marc-Berg/ioBroker.docker/issues)
* Changes: [CHANGELOG.md](CHANGELOG.md)

## License and origin

[MIT](LICENSE.md). Continuation of the [buanet/ioBroker.docker](https://github.com/buanet/ioBroker.docker) image.
