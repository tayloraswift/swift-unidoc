# Unidoc quickstart

This guide outlines how to set up and run a local Unidoc server you can use to preview your documentation as it would appear on [Swiftinit](https://swiftinit.org).

## Prerequisites

You need to have a Swift Package Manager project. Unidoc itself has little relation to SPM, but it uses the Swift toolchain to compile your project, and the Swift toolchain uses SPM to build your project.

You need to have [Docker](https://www.docker.com/) installed on your development machine. If you install it through your default package repository, we strongly recommend you ensure the installed Docker version is reasonably up-to-date (e.g. 24.0.0 or later).

It is theoretically possible to run Unidoc without Docker, but Docker makes it much easier to do so, because you will not need to (directly) manage a local [MongoDB](https://mongodb.com) deployment.


## Setting up a local database

A Unidoc server is a server that talks to a second server, a MongoDB server. Therefore, before you can start a Unidoc server, you need to set up and launch a local [MongoDB](https://github.com/tayloraswift/swift-mongodb) deployment.

A MongoDB deployment consists of a [mongod](https://www.mongodb.com/docs/manual/reference/program/mongod/) process connected to a network that the Unidoc server is also connected to.


### Starting the database server

We recommend hosting mongod inside a dedicated Docker container. This repository provides a Docker compose file that does this for you.

To bring up the mongod instance (if it is not already online), run the following:

```bash
docker compose -f Guides/docs.docc/local/docker-compose.yml up -d
```

The `-d` flag tells Docker to run the container in the background, so it does not block your terminal.


### About the Docker compose file

If you are new to Docker, it is worth taking a moment to understand the Docker compose file.

@Code(file: docker-compose.yml, title: docker-compose.yml)

This file:

1.  Launches a container from the official [`mongo:latest`](https://hub.docker.com/_/mongo) image.
2.  Sets the name of this container to `unidoc-mongod-container`.
3.  Sets the **hostname** of the container to `unidoc-mongod` **within** the `unidoc-test` network.
4.  Binds the container’s port 27017 to `localhost:27017`. This is the default port for the `mongod` process.
5.  Mounts the startup scripts and data directory within the container. This allows the documentation data to persist across container restarts.
6.  Passes a configuration file to the `mongod` process on startup.

The `unidoc-test` network is helpful for testing, but for the purposes of this tutorial, you will mostly be accessing the `mongod` process through `localhost:27017`.


## Initializing the database

The mongod instance will create a `.mongod` directory at the root of the cloned repository. This directory contains the state of the deployment, and like all database deployments, it can outlive the mongod process. This means you can kill (or crash) the mongod instance but it will not lose data unless you clear or delete its data directory.

Initialize the replica set with:

```bash
docker exec -t unidoc-mongod-container /bin/mongosh --file /unidoc-rs-init.js
```

This only needs to be done **once** per deployment lifecycle. (For example, after clearing the `.mongod` data directory.)


### Connecting to the database

Once you have a `unidoc-mongod-container` running in the background, you can start a documentation server. There are many ways to run a documentation server, but if you are developing in a Docker container, the easiest way is compile Unidoc and run the server as a normal process.

@Code(file: start-server.sh, title: start-server.sh)


### Generating certificates

If you are starting the server for the first time, you likely need to populate the `Assets/certificates/` directory with TLS certificates. See <doc:GeneratingCertificates> for instructions on how to do this.


If you did all of these steps correctly, you should be able to navigate to [`localhost:8443/`](https://localhost:8443/) and view a blank homepage.


## Populating a local documentation server

A fresh Unidoc database contains no documentation. Let’s build some now.

### Building documentation for the standard library

The documentation compiler lives in this repository, and is packaged as a normal SwiftPM executable target.

To invoke the compiler, run the `unidoc-build` tool and pass it the name of the package you want to build documentation for. In our case, the “package” is `swift`, which is a special name identifying the standard library itself.

@Code(file: load-standard-library.sh, title: load-standard-library.sh)

If you did everything correctly, you should see output that ends with something like this:

```
...

Linked documentation!
    time loading sources    : 0.0 seconds
    time linking            : 1.172033425 seconds
symbols         : 16501
Uploading symbol graph...
Successfully uploaded symbol graph!
```

Because you built these docs “abnormally” (meaning: not from a GitHub repository), they won’t show up in the homepage, but you can view them by navigating directly to [`localhost:8443/docs/swift`](https://localhost:8443/docs/swift).

>   Note:
    You may see a lot of compiler errors when building the standard library. This is expected, as the documentation for the standard library contains many errors.


### Building documentation for a local project

Building documentation for a local project is similar to building documentation for the standard library, except you need to provide a path to a directory containing the project.

Let’s try building documentation for [`swift-nio`](https://github.com/apple/swift-nio). First, we need to clone the repository.

```bash
cd /swift
git clone https://github.com/apple/swift-nio
```

**Where** you clone the repository is important, because you will need to tell Unidoc where to find the project. In this example, we cloned the repository inside a directory called `/swift`, which is a plausible place to store Git repositories in a devcontainer.

Next, you can try building `swift-nio` with `unidoc-build`, specifying the path to the search directory (`/swift`) with the `-I` option.

@Code(file: load-swift-nio.sh, title: load-swift-nio.sh)

Unidoc will launch a `swift build` process, which could take a few minutes to build the package. When the build completes, it will then compile, upload, and link the documentation. Because the documentation is local, it will have the version number `__max`, and it will not show up on the homepage. You can view it by navigating directly to [`localhost:8443/docs/swift-nio`](https://localhost:8443/docs/swift-nio).

Congratulations! You have successfully set up a local Unidoc server and previewed some documentation for a local project.


## Differences between DocC and Unidoc

There are a few key differences between DocC and Unidoc workflows to keep in mind.

### Shared database

Unlike DocC, Unidoc is specifically designed for multi-project use cases.

Although you *can* have a separate database for each project, it is usually easier to set up a single deployment per machine, with documentation that is added and updated as needed.

### Not a package plugin

DocC is a package plugin, which means you “install” it by adding it as a dependency to your `Package.swift` and invoke it through SPM. Unidoc is a toolchain and you invoke it directly on an SPM project, like `swift build`. Unlike DocC, Unidoc has no project footprint.

### Not Swiftinit

A local Unidoc server is not [Swiftinit](https://swiftinit.org) and it does not have access to Swiftinit’s package database. If you want to have a local Swiftinit-like experience, you need to populate your local Unidoc server with your packages and the packages they depend on.

