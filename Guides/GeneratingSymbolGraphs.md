# Generating symbol graphs with `symbolgraph-extract`

One way to generate a symbol graph is through the Swift Package Manager. This can be done either from the command line, or through a package plugin. But another way to do it is by running the `swift symbolgraph-extract` tool directly.

`swift symbolgraph-extract` operates on compiled swift modules, often a package’s full `.build/debug` directory. Unlike the SPM plugin, `swift symbolgraph-extract` won’t build your code automatically. This actually makes a lot of things easier, because working with SPM can be quite difficult.

`swift symbolgraph-extract` takes three mandatory parameters:

1. **`target`**

    The target triple, such as `x86_64-unknown-linux-gnu`.

2. **`module-name`**

    The name of the module to emit the symbol graph for. This is usually the same as the SPM target name, but can be different if the SPM target name has non-identifier characters in it.

3. **`output-dir`**

    The directory to write symbol graphs to. The tool doesn’t create this directory automatically.

There are several builtin modules, like `Swift` and `_Concurrency`, that can be indexed with just these three parameters. But to index user code, you have to pass an **import search path** to the tool, with the `-I` sigil. An import search path is just the `.build/debug/` directory, if you are building in debug mode.

In a typical workflow, you build your code as usual with `swift build`, passing any relevant compiler flags as part of that invocation.

```bash
$ swift build -Xcc <c flag> -Xswiftc <flag> --target <target name>
```

The example only has build flags to illustrate how to pass them, they are by no means required.

Then you index the module by invoking `swift symbolgraph-extract`.

```bash
$ swift symbolgraph-extract -pretty-print \
    -output-dir <output directory name> \
    -target <target triple name> \
    -I .build/debug \
    -module-name <module name>
```


