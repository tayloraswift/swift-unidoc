# Why does `async let` turn `rethrows` into `throws` in Swift?

If you’ve used structured concurrency in Swift enough, you may have noticed that the `rethrows` keyword doesn’t always “work” with `async`/`await`, at least according to our intuitions about when `try` should and shouldn’t be required.

This article will attempt to shed some light on how `rethrows` actually works in Swift, and explain why some `async` functions still need to be marked `throws`, even if they only call `throws` functions that were passed to them as arguments.

Suppose we have a function `Example.delay(by:_:)`, which sleeps for the specified amount of time, and then executes the closure argument, returning its result. It has the following signature and definition:

```swift
func delay<T>(by nanoseconds:UInt64, _ body:() throws -> T)
    async rethrows -> T
{
    try? await Task.sleep(nanoseconds: nanoseconds)
    return try body()
}
```

> note:
In this example, we discarded the status result of ``Task.sleep(nanoseconds:)`` using `try?` in order to emphasize the behavior of the call to `body`. Normally, we would want to detect the ``Error`` and return early to avoid having to execute `body`.

The function `Example.delay(by:_:)` is a normal Swift `rethrows` function. It is `async`, but we are still allowed to omit `try` if we pass it a non-throwing closure argument.


```swift
func delay(value:Int, by nanoseconds:UInt64)
    async -> Int
{
    await delay(by: nanoseconds){ value }
}
```

Omitting `try` also works if we use `async let` to call `Example.delay(by:_:)` on a concurrent ``Task``.


```swift
func delay(values:(Int, Int), by nanoseconds:UInt64)
    async -> (Int, Int)
{
    async let first:Int  = delay(by: nanoseconds){ values.0 }
    async let second:Int = delay(by: nanoseconds){ values.1 }
    return await (first, second)
}
```

What if we want to get an ``Int`` value from a closure? Since the inner `Example.delay(by:_:)` implementation also takes a closure parameter, we can avoid evaluating `body` in the caller, and simply forward it to the callee.

```swift
func delayInt(by nanoseconds:UInt64, _ body:() throws -> Int)
    async rethrows -> Int
{
    try await delay(by: nanoseconds, body)
}
```

Observe that `Example.delayInt(by:_:)` can be marked `rethrows`, since the inner `Example.delay(by:_:)` function is also `rethrows`. This fits with our intuition of `rethrows`.

What happens if we call `Example.delay(by:_:)` on a concurrent ``Task`` instead? We will need to constrain the `body` closure to be `@Sendable`. Even so, the `Example.delayInt2(by:_:)` example below will fail to compile, because the `try` used to `await` the `delayed` binding is not a `rethrows`-compatible `try`.

```swift
func delayInt2(by nanoseconds:UInt64, _ body:@Sendable () throws -> Int)
    async rethrows -> Int
{
    async let delayed:Int = delay(by: nanoseconds, body)
    return try await delayed
    //               ^~~~~~~
    // error: call can throw, but the error is not handled;
    // a function declared 'rethrows' may only throw if its
    // parameter does
}
```

This is not the fault of `@Sendable`. Sendability is a constraint, which means any valid `body` argument would still be valid if `@Sendable` were removed.

The reason we get a compiler error for `Example.delayInt2(by:_:)` is because `rethrows` is not actually a type-level feature. In Swift, a function is either `throws` or completely non-throwing. In fact, `rethrows` is a call-site level feature.

If we inspect the type signature of a `rethrows` function such as `Example.delayInt(by:_:)`, we can observe that the Swift compiler considers it a `throws` function.

```swift
print(type(of: delayInt(by:_:)))
// \(type(of: Example.delayInt(by:_:)))
```

Why does this even matter? If we consult the definition of `async let` from [`SE-0317`](https://github.com/apple/swift-evolution/blob/main/proposals/0317-async-let.md), we’ll notice that `async let` is defined in terms of ``Task``. This means that when we create an `async let` binding, we are implicitly creating a new ``Task``, and converting the static function call to a function object. The original `rethrows` context has no knowledge of how this function object will be called within the newly created concurrent execution context.

```swift
func delayIntWithTask(by nanoseconds:UInt64,
    _ body:@Sendable () throws -> Int)
    async rethrows -> Int
{
    let task:Task<Int, Error> = .init
    {
        try await delay(by: nanoseconds, body)
        //                               ^~~~
        // `body` was enclosed by the `Task`, which means
        // `delayIntWithTask` has no idea this is a `rethrows` call.
    }
    return try await task.value
    //                    ^~~~~
    // error: property access can throw, but the error is not handled;
    // a function declared 'rethrows' may only throw if its
    // parameter does
}
```

The upshot is that, for now, these kinds of functions still need to be marked `throws`, even if they are effectively `rethrows`.

``Task`` is unlikely to ever truly support `rethrows`, as that would require a full-scale re-architecting of the Swift type system. However, one of the more promising aspects of structured concurrency is that, in theory, we *could* statically reason about `rethrows`-like behavior for `async let` bindings, in a way that we cannot for unstructured ``Task`` objects. It remains to be seen if this will be added in a future version of Swift.
