<div align="center">

<strong><em><code>unidoc</code></em></strong><br><small><code>0.6</code></small>

[![ci build status](https://github.com/kelvin13/swift-unidoc/actions/workflows/build.yml/badge.svg)](https://github.com/kelvin13/swift-unidoc/actions/workflows/build.yml)

</div>

**Unidoc** is a scalable documentation engine for the Swift language. Unidoc can be thought of as a multi-target analogue to Apple’s local DocC compiler. It is designed for long-lived, centralized documentation indices that store, link, and serve multiple versions of documentation for many Swift packages at once.

Unidoc powers the [Swiftinit](https://swiftinit.org) open source package index!

<div align="center">

[swiftinit home](https://swiftinit.org/) · [get started locally](https://swiftinit.org/docs/swift-unidoc/guides/quickstart)

</div>



## Features

### 🪶 Small archive sizes

Unidoc servers are designed to store versioned documentation indefinitely. To achieve this, Unidoc uses a stable binary symbol graph format that can be up to two orders of magnitude smaller than an equivalent DocC archive.

Here’s a comparison for the (in)famous [SwiftSyntax](https://github.com/apple/swift-syntax) package, at version 508.0.1:

| Archive | Size | File count |
| --- | --- | --- |
| DocC (uncompressed, including synthesized symbols) | 708.0 MB | 84,619 |
| DocC (uncompressed, stripping synthesized symbols) | 155.0 MB | 17,537 |
| Unidoc (uncompressed, including synthesized symbols) | 7.8 MB | 1 |
| Unidoc (`tar.xz`, including synthesized symbols) | 611.4 KB | 1 |

> [DocC numbers sourced from Slack](https://swift-open-source.slack.com/archives/C04PCMXMBD0/p1694154083683579?thread_ts=1694101493.046719&cid=C04PCMXMBD0)


### ⬆️ Evolving documentation

You can regenerate Unidoc documentation from symbol graph archives without recompiling documentation from package sources, which historically was a [major bottleneck](https://forums.swift.org/t/navigating-html-docs-vs-generated-interfaces/67115/7) in the DocC workflow. In many situations, this means you can easily upgrade Unidoc documentation to take advantage of new features even if the underlying symbol graph was compiled by an older version of Unidoc.

You can re-link Unidoc documentation against newer versions of their package (and standard library) dependencies as they are released, without recompiling the symbol graph from source.

Unidoc databases use a cellular architecture which allows you to stagger documentation upgrades across a package index without taking the server offline.


### 🔗 Cross-package references

Unidoc can validate and resolve cross-package symbol links, including links to symbols in the standard library. This means you can link to [`String`](https://swiftinit.org/docs/swift/swift/string) in your documentation, and Unidoc will automatically generate a link to the standard library documentation for `String`.

Normal “IDE-style” symbol references, such as links to [`Int`](https://swiftinit.org/docs/swift/swift/int) within function signatures, are also supported.


### 🕸 Cross-package extensions

Unidoc can display extensions, including third-party extensions, directly in the documentation for the extended type. This means you can view [`Channel`](https://swiftinit.org/docs/swift-nio/niocore/channel) members originating from packages such as [`swift-nio-ssl`](https://github.com/apple/swift-nio-ssl) and [`swift-nio-http2`](https://github.com/apple/swift-nio-http2) from the `swift-nio` documentation itself.

In the future, we hope to support finer-grained control over third-party extensions shown in extendee documentation.


### 💞 Inherited symbols

Because Unidoc is a multi-package documentation engine, it can track and display symbols inherited from protocols in upstream dependencies, including the standard library, at negligible storage cost. This means types in third-party libraries that conform to protocols such as [`Sequence`](https://swiftinit.org/docs/swift/swift/sequence) can display and link to `Sequence` API in their member lists.


### 🌐 Unified database

Unidoc servers maintain a combined database of all documentation in their index. This allows Unidoc to serve (or redirect) individual symbol pages on-demand, instead of requiring clients to download enormous Vue.js indices for client-side rendering. This provides better performance for clients, and greatly reduces cache churn on the server as documentation is upgraded.


### 🔋 Lightweight HTML

Unidoc generates lightweight HTML documentation that uses CSS for the majority of its layout and interactivity, and serves a very low number of additional assets. This means Unidoc pages are responsive, accessible, cache-friendly, and render with minimal content-layout shift ([CLS](https://web.dev/cls/)).


### 📜 Readable signatures

Unidoc symbol graphs include line-breaking markers computed by SwiftSyntax, which allows Unidoc to display long function signatures in a readable, line-wrapped format. This makes it much easier to scan long lists of symbols with complex signatures, such as the member list of SwiftSyntax’s [`AccessPathComponentSyntax`](https://swiftinit.org/docs/swift-syntax/swiftsyntax/accesspathcomponentsyntax).


### 🚠 Per-symbol migration banners

The Unidoc server can now query successors for symbols in older (and prerelease) versions, and display a banner directing visitors to the symbol’s counterpart in the latest stable release of its package. This link is specific to the symbol, and comes with a corresponding `<link rel="canonical">` element and HTTP header.

Example: [`https://swiftinit.org/docs/swift-nio:2.57.0/niocore/eventloopgroup`](https://swiftinit.org/docs/swift-nio:2.57.0/niocore/eventloopgroup)


### ️⛳️ Symbol disambiguation pages

Unidoc is able to serve symbol disambiguation pages under the [`300 Multiple Choice`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/300) status code.

Although you should avoid creating ambiguous symbol links if possible, they are a natural occurrence as APIs evolve and overloads are added.

Example: [`https://swiftinit.org/docs/swift-certificates/x509/policyevaluationresult.failstomeetpolicy(reason:)`](https://swiftinit.org/docs/swift-certificates/x509/policyevaluationresult.failstomeetpolicy(reason:))


### 🛸 Documentation coverage

Unidoc can compute documentation coverage on a per-package and per-module basis. You can view coverage levels as pie-chart visualizations on package and module pages; see [`swift-atomics`](https://github.com/apple/swift-atomics)’s [package page](https://swiftinit.org/docs/swift-atomics) for an example.


### :octocat: GitHub integration

Unidoc can periodically index Git tags by querying the GitHub API. This feature requires a [GitHub app registration](https://docs.github.com/en/apps/oauth-apps/building-oauth-apps/differences-between-github-apps-and-oauth-apps) and app secret and is not enabled by default. Unidoc can also load repository metadata from GitHub, and use it to generate permanent links to source code on GitHub if the underlying symbol graph includes source map information.

The Unidoc compiler builds symbol graph archives with source maps by default, even if GitHub integration is not available.


### 🔐 Secure administration

When GitHub integration is available, Unidoc can use [social authentication](https://en.wikipedia.org/wiki/Social_login) to allow users to log in with their GitHub account and perform administrative actions.

As the [Swiftinit](https://swiftinit.org) index grows, we hope to allow package maintainers to claim ownership of their packages and manage their documentation directly through the Swiftinit website.


### 🔎 Search engine optimization (SEO)

Unidoc can generate, update, and serve sitemap files for search crawlers like Googlebot. This allows search engines to discover and index your documentation, and makes it easier for users to find your package.

Unidoc will make an effort to generate a `<meta>` description for every symbol in a package, even if the symbol has no documentation.

Unidoc avoids generating many copies of the same documentation, which can hinder visibility in search engines.

