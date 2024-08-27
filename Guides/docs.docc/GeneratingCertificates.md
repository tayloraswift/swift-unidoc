# Generating TLS certificates

For a seamless development experience, we recommend using [mkcert](https://github.com/FiloSottile/mkcert) to generate a local certificate authority (CA) for your development environment.

>   Note:
>   Most Unidoc users do not need to generate their own certificates. As of Unidoc 0.17.0, the preview server can run locally in insecure mode.


## Installing mkcert

### Linux

On Linux, the easiest way to install `mkcert` is to download one of its prebuilt binaries.

```bash
$ curl -JLO "https://dl.filippo.io/mkcert/latest?for=linux/amd64"
chmod +x mkcert-v*-linux-amd64
```

### macOS

On macOS, the easiest way to install `mkcert` is to use Homebrew.

```bash
$ brew install mkcert
```

## Generating a local certificate authority

```bash
$ ./mkcert-v1.4.4-linux-amd64 -install
```

On macOS, you can use the `mkcert` command directly.

```bash
$ mkcert -install
```

## Generating a local certificate

If the `mkcert-v1.4.4-linux-amd64` binary is located in your home directory, you can generate a certificate for `localhost` by running the following from the repository root:

```bash
$ mkdir -p Assets/certificates
$ cd Assets/certificates
$ ~/mkcert-v1.4.4-linux-amd64 localhost
```

(On macOS, you can use the `mkcert` command directly.)

Then, rename the generated files to `fullchain.pem` and `privkey.pem`.

```bash
$ mv localhost.pem fullchain.pem
$ mv localhost-key.pem privkey.pem
```

You should now be able to run the Unidoc server locally and access it without browser warnings.

Keep in mind that the certificate is only valid for `localhost`; hostnames like `0.0.0.0` will still raise browser warnings.
