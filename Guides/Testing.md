# Testing the Unidoc server

Unidoc uses [MongoDB](https://github.com/tayloraswift/swift-mongodb) for long-term storage of documentation. You use Unidoc by compiling documentation — anywhere the compiler can run — and then uploading the doc binaries to the Unidoc server, which mediates access to the master database.

To test the Unidoc server, you need to set up and launch a MongoDB test deployment. A MongoDB test deployment consists of a [mongod](https://www.mongodb.com/docs/manual/reference/program/mongod/) process connected to a network that the Unidoc server is also connected to.

To bring up the mongod instance (if it is not already online), run the following, from outside whatever dev container you are in:

```bash
$ docker compose -f TestDeployment/docker-compose.yml up -d
```

The mongod instance will create a `data` directory inside the `TestDeployment` directory. The `data` directory contains the state of the deployment, and like all database deployments, it can outlive the mongod process. This means you can kill (or crash) the mongod instance but it will not lose data unless you clear or delete its `data` directory.

Initialize the replica set with:

```bash
$ docker exec -t unidoc-mongod-container /bin/mongosh --file /unidoc-rs-init.js
```

This only needs to be done once per deployment lifecycle. (For example, after clearing the `data` directory.)

To actually interact with the mongod server, your dev container must be connected to its network, which is named `unidoc-test`.

This means adding the following to your docker compose container entry:

```yaml
        networks:
            - <other networks>
            - ...
            - ...
            - unidoc-test
```

And the following at the end of your docker compose file:

```yaml
networks:
    <other network>:
        name: <other network name>
        external: true
    ...
    ...
    unidoc-test:
        name: unidoc-test
        external: true
```
