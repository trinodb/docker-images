# presto-cli [![][layers-badge]][layers-link] [![][version-badge]][dockerhub-link]

[layers-badge]: https://images.microbadger.com/badges/image/teradatalabs/presto-cli.svg
[layers-link]: https://microbadger.com/images/teradatalabs/presto-cli
[version-badge]: https://images.microbadger.com/badges/version/teradatalabs/presto-cli.svg
[dockerhub-link]: https://hub.docker.com/r/teradatalabs/presto-cli

## Overview

This image contains CLI for defined version of Presto.

## Examples

To use examples below please set following environment variables:
 * `PRESTO_VERSION` - version of Presto CLI to be used
 * `PRESTO_HOST` - host on which Presto Master is visible
 * `PRESTO_PORT` - port on which Presto Master is visible (most likely 8080)

Run:
`docker run -i -t teradatalabs/presto-cli:$PRESTO_VERSION --server $PRESTO_HOST:$PRESTO_PORT`

Run single query:
`docker run -i -t teradatalabs/presto-cli:$PRESTO_VERSION --server $PRESTO_HOST:$PRESTO_PORT --execute "$QUERY"`

Build:
`docker build -t teradatalabs/presto-cli --build-arg PRESTO_VERSION=0.165-t .`

## License

By using this image, you accept OpenJDK license for Java SE, available at
[http://openjdk.java.net/legal/gplv2+ce.html](http://openjdk.java.net/legal/gplv2+ce.html).
