@path (low-level-swift-optimization)

# Low-level Swift optimization tips

This article documents several techniques I have found effective at improving the run time performance of Swift applications without resorting to “writing C in `.swift` files”. (That is, without resorting to C-like idioms and design patterns.) It also highlights a few pitfalls that often afflict Swift programmers trying to optimize Swift code.

These tips are relevant as of version 5.5 of the Swift compiler. The only reason I say this is because a few of the classical boogeymen in the Swift world, like “Objective-C bridging” and “reference counting overhead” are no longer as important as they once were.

The information in this article was originally discovered while developing the release of version [4.0](https://github.com/kelvin13/png/releases/tag/v4.0.0) of the [Swift PNG library](https://github.com/kelvin13/png), which involved replacing its `zlib` system dependency with a native Swift implementation. Because Swift is often percieved in the software industry as being a higher-level, and therefore, less efficient language compared to C and C++, it is important to ensure that switching to a native implementation does not degrade performance for users.

Reasonably well-written Swift code without any detailed optimization can easily achieve run time performance within 200 to 250 percent of a bare-metal C implementation. (Lower is better.) However, with careful measurement and optimization, Swift PNG with its pure Swift LZ77 implementation is able (as of [`075c9f7`](https://github.com/kelvin13/png/commit/075c9f7df0c7bef224f8ca9a020dc009ac3ddd2c) to run within 115 percent of its former performance. Given that `libz` is a decades-old C library with a number of hardware-specific optimizations, this is significant.

## Avoid wrapping arithmetic, and don’t truncate integers.

Some people think of the `&`ed operations as magical “fast math” operators. This is not true. In terms of speed, `&+` and friends are about as fast as `+` and friends. 

This is because the overflow check that comes with `+` always takes the the non-trapping path, so this branch is effectively free. 

At the same time, unwise usage of `&+` can actually inhibit other, higher-level compiler optimizations. For example, adding two positive ``Int``s with `+` can never produce a negative result, but adding two positive ``Int``s with `&+` can. 

The same reasoning applies to ``FixedWidthInteger.init(truncatingIfNeeded:)`` and ``FixedWidthInteger.init(_:)``. The Swift compiler can infer that casting an ``Int`` to a ``UInt8`` through ``FixedWidthInteger.init(_:)`` always yields the same integer, because the program will trap on overflow. The same cannot be said for ``FixedWidthInteger.init(truncatingIfNeeded:)``.

## Use shorter integer types for buffer elements.

Philosophically, Swift encourages you to exclusively use ``Int`` for modeling numerical values, and to avoid using width-specific types such as ``Int32``, ``Int16``, etc. For local variables and computed properties, this is good advice. In fact, for most *stored* properties, this is still good advice. 

Sometimes though, you need to store many, many instances of something in a very large buffer. In such situations, it’s worthwhile to use the shorter integer types for backing storage if the full range of ``Int`` or ``UInt`` is not required. This both saves memory, and greatly improves cache locality. For high-traffic data, such as lookup tables, the performance gain from improved cache locality can be significant. 

Using smaller integers for backing storage does not mean you have to give up the universal ``Int`` convention in your API. Indeed, this was the exact problem property-wrappers are intended to solve. This technique can be very effective at reducing the memory footprint of a [`struct`]().

```swift
@propertyWrapper 
struct CompactInt<T> where T:FixedWidthInteger 
{
    var projectedValue:T 
    
    init(wrappedValue:Int) 
    {
        self.projectedValue = .init(truncatingIfNeeded: wrappedValue)
    }
    var wrappedValue:Int 
    {
        .init(self.projectedValue)
    }
}
```

> note:
You can also optimize the storage of a [`class`]() this way, though this is unlikely to result in a performance gain, since the [`class`]() is already heap-allocated.

## Avoid [`@inline(__always)`]().

Many people treat [`@inline(__always)`]() as a magical *make this faster* keyword that you can just sprinkle around the hot paths of your code. (In some respects, it’s a lot like `&+`.) This is not true. Blindly adding [`@inline(__always)`]() annotations can actually slow your code down. The reason for this is that inlining functions increases code size, which means that the processor now needs to use additional cache space just to load its instructions. The concept of cache-friendliness applies to code just as much as it does to data! While inlining can improve performance, the compiler almost always makes better inlining decisions than you will, so you’re better off avoiding this attribute.

For that matter, while there’s rarely a reason to use it directly, [`@inline(never)`]() can be a useful tool for determining how inlining is impacting the performance of your code. The compiler can also be a little over-aggressive when it comes to inlining, so in rare cases, explicitly adding this annotation can actually help performance.

> note:
[`@inline(__always)`]() is not the same as [`@inlinable`](), which almost always does improve performance (for downstream module users), and absolutely should be used when ABI considerations allow for it.

## Don’t use capture lists if you don’t need to.

Sometimes, people coming from a C background feel like they need to “localize” enclosed variables by adding them to the closure’s capture list. This is because, in the C world, you are used to hearing the word *closure context* and immediately imagining horrifying scenarios where every variable access from the enclosing scope is doubly reference-counted and hidden behind twelve layers of indirection. 

In some languages with a heavy runtime, this is true. Swift is not one of those languages. 

As long as the closure is non [`@escaping`](), it will execute just like a normal function call. For a closure, accessing enclosed variables, including [`self`](), is just a matter of accessing values in the stack frame immediately below the closure’s own, which is rarely more than a few bytes away.

Adding enclosed variables to a closure’s capture list will often *harm* performance because the captured variables need to be pushed onto the stack whenever the closure is called, just so that it has a fresh copy for itself. In effect, captured variables are just additional function arguments which will incur function call overhead. 

Oftentimes, the Swift compiler is able to optimize away the capture-copy, so this does not actually end up hurting the performance of the compiled binary. But there are a lot of ways the compiler can fail to optimize something, and there is really no reason to add variables to a capture list anyway, unless it is actually important to the semantics of the code.

## Don’t manually vectorize loops. Instead, preserve vectorization conditions.

The Swift compiler is *very* good at automatically vectorizing loops. Sometimes it will even vectorize things you never thought could be vectorized in the first place. Naturally, this means trying to do it yourself with the various standard library ``SIMD`` constructs will just get in the way, and will often make your code slower, not faster.

Loop vectorization is a well-studied problem in computer science. The Swift compiler is built on LLVM, which means the Swift compiler knows about all of the optimization techniques that LLVM knows about.

If you really want to optimize for vectorization, focus on reducing the amount of branching in the loop body, and simplifying the control flow in general. This will make it easier for the Swift compiler to perform the automated vectorization transformations.

## Use ``ManagedBuffer`` instead of ``UnsafeMutableBufferPointer``.

Many Swift programmers try to make ``Array``s faster by switching to ``UnsafeMutableBufferPointer`` and/or related types, and performing manual memory management, as you would in a language like C or C++. This often causes problems when integrated into a larger Swift codebase since the language is geared around value semantics and automated memory management. A commonly-perscribed remedy is to wrap the buffer pointer in a [`class`](), which lets you do cleanup in the [`class`]()’s [`deinit`]() method. 

This has the performance drawback of placing the buffer’s storage behind two layers of heap indirection: one for the [`class`](), and one for the buffer pointer. A better solution is to use the standard library’s ``ManagedBuffer`` type, which allows you to store buffer elements as inline data within the allocation of the [`class`]().

## Don’t put ``Array.count`` and ``Array.capacity`` in the buffer header.

In general, array bounds checks themselves are not what cause ``Array``s to be slower than ``ManagedBuffer``s, but rather the memory accesses to the ``Array.count`` and ``Array.capacity`` properties stored in the array header. 

It follows that attempting to reimplement an ``Array`` using a ``ManagedBuffer`` with the buffer parameters stored in the ``Header`` will not improve upon the performance of ``Array``. In fact, moving additional properties that would have otherwise gone into a wrapper [`struct`]() containing an ``Array`` into the ``Header`` can actually *worsen* performance.

To understand why accesses to ``Array.count`` and ``Array.capacity`` matter, consider the memory access pattern of buffer reads and writes compared to typical memory access patterns when using dynamic arrays in general. Buffer reads and writes almost always form a streaming pattern where accesses move away from the front of the buffer over time. However, because ``Array.count`` and ``Array.capacity`` live in the buffer header, which is located at the front of the buffer, this forces the processor to switch back and forth between increasingly distant memory locations. 

To fix this, set the buffer’s `Header` type to ``Void``, and store the ``Array.count`` and ``Array.capacity`` in a [`struct`]() that also contains the ``ManagedBuffer``. This signals to the compiler that the ``Array.count``, ``Array.capacity``, and pointer to the buffer head (the [`class`]() reference) should all live on the stack. As long as you have implemented the wrapping structure’s copy-on-write functionality correctly, doing this will have no effect on the buffer’s semantics.

This is especially important if you are storing sub-buffers at dynamic offsets within your buffer. Accessing sub-buffers through offsets stored inline within a ``ManagedBuffer`` is often no better than wrapping an ``UnsafeMutableBufferPointer`` in a [`class`]().

Why is ``Array`` not implemented like this? One reason is that it would now have a footprint of three words (one for the storage pointer, one for the ``Array.count``, and one for the ``Array.capacity``.) Another reason is that the optimizer and the standard library tend to assume that ``Element`` reads and writes are uniformly distributed across the array. Finally, ``Array``s being used as buffers are usually much larger than a “typical” ``Array``. This means that normally, accessing ``Array.count`` and ``Array.capacity`` is not a problem, and an ``Array`` would be better off represented with just a single word — the storage pointer.

## Don’t use ``Dictionary.init(grouping:by:)``.

``Dictionary.init(grouping:by:)`` seems to exhibit exceptionally poor performance, compared to a naive two-pass bucketing algorithm. (One pass to determine the sub-array counts, and one pass to populate the sub-arrays.)

Only use ``Dictionary.init(grouping:by:)`` if you have a single-pass ``Sequence`` and absolutely need the ``Dictionary`` output format.

## Some C/C++ advice still applies.

Some advice for optimizing C or C++ code still applies to Swift, namely:

-   A consolidated storage array combined with an array of [`Range<Int>`]() intervals is faster than a nested array, due to improved memory locality.

-   Properly-aligned consolidated lookup tables are faster than separately-allocated lookup tables, due to improved memory locality.

-   Bit shifting by a multiple of 8 is faster than shifting by a non-multiple of 8, since the first case translates into a simple byte-level load and store. This means it is faster to first build a wide integer out of component bytes, and then shift the wide integer, than to shift the components individually.

-   Bit twiddling isn’t free. It is faster to read from a small lookup table (less than 512 bytes) living in the L1 cache than it is to execute a sequence of more than 5 or 6 arithmetic/logic instructions.
