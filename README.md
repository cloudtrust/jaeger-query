# Jaeger query

Jaeger query retrieves traces from the Elasticsearch storage and provides UI to display them.

This repository contains our jaeger-query dockerfile. For our needs, it makes sense to have as little dynamic parts as possible. We only need to manage the Jaeger query's configuration.

## Building the dockerfile

We recommend running the build tasks via our deployment procedure, but in case you want to build it yourself, there are many build arguments to pass. You can learn about them by reading the dockerfile.

## Running jaeger-query

Depending on the config repo, the container could expect some names to be reachable. Refer to the specifics of the configuration repo.

An example run command should look like

```Bash
# Run the container
docker run --rm -it --net=ct_bridge --tmpfs /tmp --tmpfs /run -v /sys/fs/cgroup:/sys/fs/cgroup:ro --name jaeger-query -p 16686:80 cloudtrust-jaeger-query
```

Note that the storage backend must be available and correctly configured, otherwise the Jaeger UI won't work. See the cloudtrust [elasticsearch-data-service](https://github.com/cloudtrust/elasticsearch-data-service) repository for more information on the storage.


## Configuration
The JSON `deploy/etc/jaeger-query/ui-config` (See [configuration](https://github.com/cloudtrust/dev-config) repo) allows you to configure multiple aspects of the UI, like the top menu (see [documentation](https://jaeger.readthedocs.io/en/latest/deployment/)).

The remaining part of the Jaeger query and Jaeger UI is configured in the file `deploy/etc/jaeger-query/query.yml`.
