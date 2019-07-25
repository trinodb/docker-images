# docker-dnsmasq

[dnsmasq][dnsmasq] requires `NET_ADMIN` capabilities to run correctly. Start it with something like `docker run -p 53:53/tcp -p 53:53/udp --cap-add=NET_ADMIN prestodev/dns:2.75`.

The configuration is all handled on the command line (no wrapper scripts here). The `ENTRYPOINT` is `dnsmasq -k` to keep it running in the foreground. If you wanted to send requests for an internal domain (such as Consul) you can forward the requests upstream using something like `docker run -p 53:53/tcp -p 53:53/udp --cap-add=NET_ADMIN prestodev/dns:2.75 -S /consul/10.17.0.2`. This will send a request for `redis.service.consul` to `10.17.0.2`

As this is a very barebones entrypoint with just enough to run in the foreground, there is no logging enabled by default. To send logging to stdout you can add `--log-facility=-` as an option.

[dnsmasq]: http://www.thekelleys.org.uk/dnsmasq/doc.html
