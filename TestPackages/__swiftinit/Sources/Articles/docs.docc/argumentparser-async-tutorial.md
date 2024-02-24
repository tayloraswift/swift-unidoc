# How to use `ArgumentParser` with `async`/`await` in Swift

If you’ve adopted structured concurrency in your applications since it landed in Swift 5.5, you may have found that the ``ArgumentParser`` module does not yet work with an `async` `main` function out-of-the-box.

Fortunately, ``ArgumentParser`` actually *does* support applications with asynchronous `main` functions, although this functionality is not exposed by default. In this tutorial, we’ll go over how to enable the experimental `async` support in ``ArgumentParser``, and how to port your ``ParsableCommand``s over to the new API without resorting to hacks such as manually handling ``CommandLine`` arguments or invoking parsers.

## Switching to the `async` branch

As of ``ArgumentParser`` 1.0.2, `async` support is only enabled in the [`apple/swift-argument-parser:async`](https://github.com/apple/swift-argument-parser/tree/async) branch. To compile against the `async` branch, set the ``PackageDescription.Dependency.Requirement`` for the ``ArgumentParser`` dependency in your `Package.swift` file to [`.branch("async")`]():

```swift
dependencies:
[
    .package(url: "https://github.com/apple/swift-argument-parser",
        .branch("async")),
]
```

## Using the ``AsyncMain`` protocol

Because ``ArgumentParser`` allows us to implement more than one ``ParsableCommand`` per application, we normally annotate the command we want to designate as the base command with the `@main` attribute. A protocol extension on ``ParsableCommand`` provides the `static main` function required by `@main`.

```swift
import protocol ArgumentParser.ParsableCommand

@main
enum Tool:ParsableCommand
{
    static
    var configuration:CommandConfiguration = ...

    func run() throws
    {
        ...
    }
}
```

> note:
In Swift, any type can be marked `@main`, as long as it provides a `static func main()`.

In an effort to be helpful, ``ParsableCommand`` will always provide an implementation of `main`. This implementation is a *synchronous* placeholder that just prints your tool’s help message and exits. If you implement your own *asynchronous* `main`, or ask ``ArgumentParser`` to implement it for you, the compiler will not know which `main` function to run when the build product executes.

```swift
// in the ArgumentParser module
extension ParsableCommand
{
    static
    func main() throws
    {
        ...
    }
}
```
```swift
extension Tool
{
    static
    func main() async throws
    {
        ...
    }
}
```
> note:
The `async` `Tool.main` method does not override the synchronous `main` from the protocol extension, because Swift allows overloading on `async`.

To solve this problem, ``ArgumentParser`` provides the `protocol AsyncMain`.

Define a new type `Main`, and conform it to ``AsyncMain``. This protocol takes an associated ``AsyncMain.Command`` type, which should be set to your original base command. Move the `@main` attribute to the new Main type.

Asynchronous commands should be updated to conform to ``ArgumentParser.AsyncParsableCommand`` instead of ``ArgumentParser.ParsableCommand``.

```swift
import protocol ArgumentParser.AsyncMain
import protocol ArgumentParser.AsyncParsableCommand

@main
enum Main:AsyncMain
{
    typealias Command = Tool
}
enum Tool:AsyncParsableCommand
{
    static
    var configuration:CommandConfiguration = ...

    func run() async throws
    {
        ...
    }
}
```
```swift
// in the ArgumentParser module
extension AsyncParsableCommand
{
    static
    func main() async throws
    {
        ...
    }
}
```

## Conclusion

As we have seen, it is not necessary to drop down to a lower-level API in order to use `async`/`await` with the Swift ``ArgumentParser`` module.

Hopefully, this tutorial helped you!
