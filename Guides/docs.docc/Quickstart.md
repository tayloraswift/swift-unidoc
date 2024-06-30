# Previewing documentation locally

This guide walks through how to use the `unidoc-preview` tool to preview documentation locally on macOS 14. This guide won’t make any effort to explain how Unidoc itself works, it is merely intended to demonstrate how to preview multi-package documentation as quickly as possible. For a more-detailed Linux-centric tour, see the <doc:Getting-started> guide.

In this guide, you will:

1.  Launch and initialize a `mongod` instance in a Docker container,
2.  Build and run an instance of `unidoc-preview` on the macOS host,
3.  Build the `unidoc-build` tool,
4.  Generate documentation for the standard library, and
5.  Generate documentation for two SwiftPM packages, one of which depends on the other.

Before you begin, clone the Unidoc repository and navigate to the root of the repository:

```bash
git clone https://github.com/tayloraswift/swift-unidoc
cd swift-unidoc
```

## 1. Install Docker

The easiest way by far to preview documentation locally is to use Docker. You can download Docker Desktop for macOS from the [official website](https://www.docker.com/products/docker-desktop).


## 2. Launching a `mongod` instance

Use Docker Compose to launch a `mongod` instance in a container. This container is named `unidoc-mongod-container`. It has persistent state which `mongod` stores in a directory called `.mongod` at the root of the repository.

```bash
docker compose -f Guides/docs.docc/local/docker-compose.yml up
```

The container is home to a MongoDB [replica set](https://www.mongodb.com/docs/manual/reference/replica-configuration/) which you need to initialize.

Open a new terminal and run the following command to initialize the replica set:

```bash
docker exec -t unidoc-mongod-container /bin/mongosh --file /unidoc-rs-init.js
```


## 3. Running `unidoc-preview`

The `unidoc-preview` tool is an ordinary SwiftPM executable product. You can build and run it directly from your macOS host like this:

```bash
swift run -c release unidoc-preview
```

The `unidoc-preview` tool will start a web server on [http://localhost:8080](http://localhost:8080).


## 4. Generating documentation for the standard library

Generate local documentation using the `unidoc-build local` subcommand. To start off, open a third terminal and generate the documentation for the standard library (`swift`).

@Code(file: load-standard-library.sh, title: load-standard-library.sh)

You should be able to view the symbol graph and its documentation at [http://localhost:8080/tags/swift](localhost:8080/tags/swift).

## 5. Generating documentation for SwiftPM packages

Now, let’s generate documentation for [swift-collections](https://github.com/apple/swift-collections), a popular SwiftPM package. Download the library’s source code to a sibling directory.

```bash
cd ..
git clone https://github.com/apple/swift-collections
cd -
```

Generating documentation for a package is similar to generating documentation for the standard library, except you need to specify a search path to a directory containing the project. Because you downloaded the `swift-collections` repository to a sibling directory, you can use `..` for the search path.

```bash
swift run -c release unidoc-build local swift-collections -I ..
```

Now, let’s generate documentation for a package that depends on `swift-collections`. Download the source code for [swift-async-algorithms](https://github.com/apple/swift-async-algorithms) to another sibling directory.

```bash
cd ..
git clone https://github.com/apple/swift-async-algorithms
cd -
swift run -c release unidoc-build local swift-async-algorithms -I ..
```
