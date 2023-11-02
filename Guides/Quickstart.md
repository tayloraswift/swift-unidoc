# Unidoc quickstart

This guide outlines how to set up and run a local Unidoc server you can use to preview your documentation as it would appear on [Swiftinit](https://swiftinit.org).

## Prerequisites

You need to have a Swift Package Manager project. Unidoc itself has little relation to SPM, but it uses the swift toolchain to compile your project, and the swift toolchain uses SPM to build your project.

You need to have [Docker](https://www.docker.com/) installed on your development machine. If you install it through your default package repository, we strongly recommend you ensure the installed Docker version is reasonably up-to-date (e.g. 24.0.0 or later).

It is theoretically possible to run Unidoc without Docker, but Docker makes it much easier to do so, because you will not need to (directly) manage a local [MongoDB](https://mongodb.com) deployment.

## Differences between DocC and Unidoc

To manage expectations, there are a few key differences between DocC and Unidoc workflows to keep in mind.

### Shared database

Unlike DocC, Unidoc is specifically designed for multi-project use cases.

Although you *can* have a separate database for each project, it is usually easier to set up a single deployment per machine, with documentation that is added and updated as needed.

### Not a package plugin

DocC is a package plugin, which means you “install” it by adding it as a dependency to your `Package.swift` and invoke it through SPM. Unidoc is a toolchain and you invoke it directly on an SPM project, like `swift build`. Unlike DocC (and other hosting providers like the Swift Package Index), Unidoc has no project footprint.

### Not Swiftinit

A local Unidoc server is not [Swiftinit](https://swiftinit.org) and it does not have access to Swiftinit’s package database. If you want to have a local Swiftinit-like experience, you need to populate your local Unidoc server with your packages and the packages they depend on.

## Setting up a local database

Unidoc uses [MongoDB](https://github.com/tayloraswift/swift-mongodb) for long-term storage of documentation. You use Unidoc by compiling documentation (more on that later) and then uploading the docs to a Unidoc server, which mediates access to the master database.

A Unidoc server is a server that talks to a second server, a MongoDB server. Therefore, before you can start a Unidoc server, you need to set up and launch a local MongoDB deployment.

A MongoDB deployment consists of a [mongod](https://www.mongodb.com/docs/manual/reference/program/mongod/) process connected to a network that the Unidoc server is also connected to.

### Starting the database server

Even if you have a mongod daemon running on your development machine, it is usually preferable to host mongod inside a dedicated Docker container. This repository provides a Docker compose file that does this for you.

To bring up the mongod instance (if it is not already online), run the following:

```bash
$ docker compose -f Local/Deployment/docker-compose.yml up -d
```

The `-d` flag tells Docker to run the container in the background, so it does not block your terminal.

### Initializing the database

The mongod instance will create a `data` directory inside the `Local/Deployment` directory. The `data` directory contains the state of the deployment, and like all database deployments, it can outlive the mongod process. This means you can kill (or crash) the mongod instance but it will not lose data unless you clear or delete its `data` directory.

Initialize the replica set with:

```bash
$ docker exec -t unidoc-mongod-container /bin/mongosh --file /unidoc-rs-init.js
```

This only needs to be done **once** per deployment lifecycle. (For example, after clearing the `data` directory.)

### Connecting to the database

The Docker compose configuration we provide contains a subnet named `unidoc-test`. All participating containers must be connected to this network to be able to communicate with each other.

>   Note:
>   If you are also *developing* from a container, it is not strictly necessary for the development container to be connected to this network. However, it is often convenient to configure your development environment to be part of the `unidoc-test` network. Among other things, this allows you to run Unidoc tools from the development container instead of from a separate container.

## Starting a local documentation server

Once you have a `unidoc-mongod-container` running in the background, you can start a documentation server.

### Generating certificates

If you are starting the server for the first time, you likely need to populate the `Local/Server/Certificates` directory with TLS certificates. See <doc:GeneratingCertificates> for instructions on how to do this.

### Starting the documentation server

Like the MongoDB server, the documentation server runs in a container. You can bring it online with Docker compose.

```bash
$ docker compose -f Local/Server/docker-compose.yml up
```

The documentation server runs in a container called `unidoc-server-container` and binds to port 8443. From **other containers** connected to the `unidoc-test` network, it has the hostname `unidoc-local`.

From the host machine, which is not connected to the `unidoc-test` network, you can only access the server through [`localhost:8443`](`https://localhost:8443`).

## Populating a local documentation server

A fresh Unidoc database contains no documentation. Let’s build some now.

The simplest way to build documentation is to use our prebuilt Docker image, which you can pull from [`tayloraswift/unidoc`](https://hub.docker.com/repository/docker/tayloraswift/unidoc/general). For this exercise, you don’t need any Docker compose layers, so you can just launch a container from the base image in your terminal.

```bash
$ docker run -it --rm \
    --entrypoint=/bin/bash \
    --network=unidoc-test \
    tayloraswift/unidoc:latest
```

### Building documentation for the standard library

Inside the container, run the `unidoc-build` command and pass it a single argument, which is the name of the package you want to build documentation for. In our case, the “package” is `swift`, which is a special name identifying the standard library itself.

```bash
# unidoc-build swift -f
```

If you navigate to [`localhost:8443/`](https://localhost:8443/) in a browser, you should notice a new documentation volume under **Recent docs** named *swift*.

Exit the container now.

```bash
# exit
```

### Building documentation for a local project

Building documentation for a local project is similar to building documentation for the standard library, except you need to provide a path to a directory containing the project.

Let’s try building documentation for [`swift-nio`](https://github.com/apple/swift-nio). First, we need to clone the repository.

```bash
$ git clone https://github.com/apple/swift-nio
```

Next, launch another container, this time mounting the `swift-nio` directory as a Docker volume at the path `/projects/swift-nio`.

```bash
$ docker run -it --rm \
    --entrypoint=/bin/bash \
    --network=unidoc-test \
    --volume=$PWD/swift-nio:/projects/swift-nio \
    tayloraswift/unidoc:latest
```

Inside the container, run `unidoc-build`, and pass the path to the `/projects` directory to the `--input` option. Use `swift-nio` as the package name; this **must** match the name of project directory.

```bash
# unidoc-build swift-nio -f --input /projects
```

Unidoc will then launch a `swift build` process, which could take a few minutes. It will then compile, upload, and link the documentation, which should take a few seconds. When it is done, you should see a new documentation volume under **Recent docs** named *swift-nio*. Because the documentation is local, it will have the version number `0.0.0`.

>   Note:
>   If the `swift build` process fails, make sure you did not attempt to build the package locally before. If you did, your host-generated build artifacts will conflict with the container-generated build artifacts, and the build will fail. You can fix this by deleting the `.build` directory in the project directory.

## Advanced workflows

Using the `unidoc` Docker image is great for getting started quickly, but it’s not a great workflow for iterating frequently, since the container builds will conflict with your incremental builds.

A better workflow is to connect your development environment to the `unidoc-test` network and run the Unidoc tools from your development environment.

---

TODO: explain what this means

---

Adding the following to your docker compose container entry:

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
