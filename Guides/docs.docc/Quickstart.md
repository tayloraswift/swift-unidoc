# Previewing documentation locally

This guide walks through how to use the `unidoc preview` tool to preview documentation locally on macOS 14. This guide won’t make any effort to explain how Unidoc itself works, it is merely intended to demonstrate how to preview multi-package documentation as quickly as possible. For a more-detailed Linux-centric tour, see the <doc:Getting-started> guide.

In this guide, you will:

1.  Launch and initialize a `mongod` instance in a Docker container,
2.  Build or install Unidoc on the macOS host,
3.  Run an instance of `unidoc preview` on the macOS host,
4.  Generate documentation for the standard library, and
5.  Generate documentation for two SwiftPM packages, one of which depends on the other.


## 1. Install Docker

The easiest way by far to preview documentation locally is to use Docker. You can download Docker Desktop for macOS from the [official website](https://www.docker.com/products/docker-desktop).


## 2. Install Unidoc

Today, there are two main ways to install Unidoc — building it from source or downloading a pre-built binary.

### Downloading a pre-built binary

Pre-built binaries are available for a limited set of platforms.

| Platform | Download |
|----------|----------|
| macOS    | [`macOS-ARM64/unidoc.gz`](https://static.swiftinit.org/unidoc/0.19.0/macOS-ARM64/unidoc.gz) |
| Linux    | [`Linux-X64/unidoc.gz`](https://static.swiftinit.org/unidoc/0.19.0/Linux-X64/unidoc.gz) |


You can download and install the binary in your home directory like this:

@Code(file: unidoc-install.sh, title: unidoc-install.sh)


### Building Unidoc from source

Unidoc is an ordinary SwiftPM executable product. You can build it for your macOS host like this:

@Code(file: unidoc-from-source.sh, title: unidoc-from-source.sh)

Please note that the executable as built by SwiftPM is named `unidoc-tools`, which you should rename to `unidoc` when installing it.


>   Important:
>   The rest of this guide assumes you have installed Unidoc somewhere on your macOS host that is visible in your `PATH` and allows you to invoke it as `unidoc`.


## 3. Launching a `mongod` instance

If you have not already done so, clone the Unidoc project and navigate to the root of the repository:

```bash
git clone https://github.com/tayloraswift/swift-unidoc
cd swift-unidoc
```

Use Docker Compose to launch a `mongod` instance in a container. This container is named `unidoc-mongod-container`. It has persistent state which `mongod` stores in a directory called `.mongod` at the root of the repository.

```bash
docker compose -f Guides/docs.docc/local/docker-compose.yml up
```

@Image(source: "Docker Desktop.png", alt: "Docker Desktop") {
>   You should see the `unidoc-mongod-container` running in the Docker Desktop GUI.
}


The container is home to a MongoDB [replica set](https://www.mongodb.com/docs/manual/reference/replica-configuration/) which you need to initialize.

Open a new terminal and run the following command to initialize the replica set:

```bash
docker exec -t unidoc-mongod-container /bin/mongosh --file /unidoc-rs-init.js
```


## 3. Running `unidoc preview`

The `unidoc preview` tool is a simple web server that links and serves documentation for local Swift packages. Run it directly from your macOS host like this:

```bash
unidoc preview
```

The `unidoc preview` tool will start a web server on [`http://localhost:8080`](http://localhost:8080).

@Image(source: "Start page.png", alt: "Start page") {
>   The `unidoc preview` start page.
}

## 4. Generating documentation for the standard library

Generate local documentation using the `unidoc local` subcommand. To start off, open a third terminal and generate the documentation for the standard library (`swift`).

```bash
unidoc local swift
```

You should be able to view the symbol graph and its documentation at [`http://localhost:8080/tags/swift`](http://localhost:8080/tags/swift).

@Image(source: "Standard library tags.png", alt: "Standard library") {
>   The standard library documentation. We generated it using the default Xcode toolchain, so it’s labeled `__Xcode`.
}


## 5. Generating documentation for SwiftPM packages

Now, let’s generate documentation for [swift-collections](https://github.com/apple/swift-collections), a popular SwiftPM package. Download the library’s source code to a sibling directory.

```bash
cd ..
git clone https://github.com/apple/swift-collections
cd -
```

Generating documentation for a package is similar to generating documentation for the standard library, except you need to specify a search path to a directory containing the project. Because you downloaded the `swift-collections` repository to a sibling directory, you can use `..` for the search path.

```bash
unidoc local swift-collections -I ..
```

You should be able to view the symbol graph and its documentation at [`http://localhost:8080/tags/swift-collections`](http://localhost:8080/tags/swift-collections).

@Image(source: "Swift Collections tags.png", alt: "Swift Collections") {
>   The `swift-collections` documentation.
}

Finally, let’s generate documentation for a package that depends on `swift-collections`. Download the source code for [swift-async-algorithms](https://github.com/apple/swift-async-algorithms) to another sibling directory.

```bash
cd ..
git clone https://github.com/apple/swift-async-algorithms
cd -
unidoc local swift-async-algorithms -I ..
```


@Image(source: "Swift Async Algorithms tags.png", alt: "Swift Async Algorithms") {
>   The `swift-async-algorithms` documentation. Observe that it has a linked dependency on the `swift-collections` documentation you generated earlier.
}

Please note that when you link documentation for a SwiftPM package against another package, it is your responsibility to ensure that the two versions are ABI-compatible. Many SwiftPM packages are not ABI-stable, so you should always check that the root package is being built with the same versions of its dependencies as you generated their documentation from.
