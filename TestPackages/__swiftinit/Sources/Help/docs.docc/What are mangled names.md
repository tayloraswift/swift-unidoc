# What are mangled names in Swift?

Mangled names are a way to encode the type signatures of symbols in Swift. This helps Swift differentiate between overloaded functions at runtime. Learning to use mangled names can highly advantageous when debugging Swift code. Read this article to quickly understand mangled names and how they are used in Swift.

Here’s an example of a mangled name:

```
sScS12ContinuationV5yieldyAB11YieldResultOyx__GxnF
```

You can demangle a mangled name using the `swift-demangle` tool. This tool is included with the Swift toolchain.

Here is an example of how to demangle a mangled name:

```sh
$ swift-demangle sScS12ContinuationV5yieldyAB11YieldResultOyx__GxnF
$sScS12ContinuationV5yieldyAB11YieldResultOyx__GxnF --->
Swift.AsyncStream.Continuation.yield(__owned A) -> Swift.AsyncStream<A>.Continuation.YieldResult
```

After demangling the symbol name, you can see that it represents ``AsyncStream.Continuation.yield(_:)``.

## Mangled names and Swift ABI stability

Mangled names are part of the Swift ABI, which means that changing the mangled name of a symbol can break binary compatibility.

For example, if you change the signature of a function, the mangled name will change. This means that any code that calls that function will need to be recompiled to use the new mangled name.

## Mangled names and Swift documentation

Mangled names influence Swift documentation stability in a similar way to the Swift ABI. For example, the Unidoc engine uses mangled names to correlate documentation between different versions of Swift libraries. The DocC tool uses mangled names to disambiguate code references in documentation. The DocC tool generates DocC hashes from mangled names, so code references that use hashes are affected by changes to mangled names.

Unqualified code references in documentation are not mangled, so they are not affected by changes to mangled names.

## Where might I encounter mangled names?

Some ways you might encounter mangled names include:

- When symbolicating crash dumps,

- When debugging Swift binaries,

- When linking Swift binaries against different versions of libraries than they were built with,

- When working with Swift libraries that use the Swift ABI, and

- When measuring changes between different versions of the same Swift library.

## Why do some Swift symbols have short mangled names?

Some symbols in the Swift standard library have been assigned short mangled names to help reduce binary sizes. For example, the mangled name for ``Int`` is `sSi`. Learning to recognize these short mangled names can be helpful when debugging Swift code.

Here are some common short mangled names:

| Name  | Human readable name                           |
|-------|-----------------------------------------------|
| `sSa` | ``Swift/Array``                               |
| `sSB` | ``Swift/BinaryFloatingPoint``                 |
| `sSb` | ``Swift/Bool``                                |
| `sSD` | ``Swift/Dictionary``                          |
| `sSd` | ``Swift/Float64``                             |
| `sSE` | ``Swift/Encodable``                           |
| `sSe` | ``Swift/Decodable``                           |
| `sSF` | ``Swift/FloatingPoint``                       |
| `sSf` | ``Swift/Float32``                             |
| `sSG` | ``Swift/RandomNumberGenerator``               |
| `sSH` | ``Swift/Hashable``                            |
| `sSh` | ``Swift/Set``                                 |
| `sSI` | ``Swift/DefaultIndices``                      |
| `sSi` | ``Swift/Int``                                 |
| `sSJ` | ``Swift/Character``                           |
| `sSj` | ``Swift/Numeric``                             |
| `sSK` | ``Swift/BidirectionalCollection``             |
| `sSk` | ``Swift/RandomAccessCollection``              |
| `sSL` | ``Swift/Comparable``                          |
| `sSl` | ``Swift/Collection``                          |
| `sSM` | ``Swift/MutableCollection``                   |
| `sSm` | ``Swift/RangeReplaceableCollection``          |
| `sSN` | ``Swift/ClosedRange``                         |
| `sSn` | ``Swift/Range``                               |
| `sSO` | ``Swift/ObjectIdentifier``                    |
| `sSP` | ``Swift/UnsafePointer``                       |
| `sSp` | ``Swift/UnsafeMutablePointer``                |
| `sSQ` | ``Swift/Equatable``                           |
| `sSq` | ``Swift/Optional``                            |
| `sSR` | ``Swift/UnsafeBufferPointer``                 |
| `sSr` | ``Swift/UnsafeMutableBufferPointer``          |
| `sSS` | ``Swift/String``                              |
| `sSs` | ``Swift/Substring``                           |
| `sST` | ``Swift/Sequence``                            |
| `sSt` | ``Swift/IteratorProtocol``                    |
| `sSU` | ``Swift/UnsignedInteger``                     |
| `sSu` | ``Swift/UInt``                                |
| `sSV` | ``Swift/UnsafeRawPointer``                    |
| `sSv` | ``Swift/UnsafeMutableRawPointer``             |
| `sSW` | ``Swift/UnsafeRawBufferPointer``              |
| `sSw` | ``Swift/UnsafeMutableRawBufferPointer``       |
| `sSX` | ``Swift/RangeExpression``                     |
| `sSx` | ``Swift/Strideable``                          |
| `sSY` | ``Swift/RawRepresentable``                    |
| `sSy` | ``Swift/StringProtocol``                      |
| `sSZ` | ``Swift/SignedInteger``                       |
| `sSz` | ``Swift/BinaryInteger``                       |
| `sScA`| ``_Concurrency/Actor``                        |
| `sScC`| ``_Concurrency/CheckedContinuation``          |
| `sScc`| ``_Concurrency/UnsafeContinuation``           |
| `sScE`| ``_Concurrency/CancellationError``            |
| `sSce`| ``_Concurrency/UnownedSerialExecutor``        |
| `sScF`| ``_Concurrency/Executor``                     |
| `sScf`| ``_Concurrency/SerialExecutor``               |
| `sScG`| ``_Concurrency/TaskGroup``                    |
| `sScg`| ``_Concurrency/ThrowingTaskGroup``            |
| `sScI`| ``_Concurrency/AsyncIteratorProtocol``        |
| `sSci`| ``_Concurrency/AsyncSequence``                |
| `sScJ`| ``_Concurrency/UnownedJob``                   |
| `sScM`| ``_Concurrency/MainActor``                    |
| `sScP`| ``_Concurrency/TaskPriority``                 |
| `sScS`| ``_Concurrency/AsyncStream``                  |
| `sScs`| ``_Concurrency/AsyncThrowingStream``          |
| `sScT`| ``_Concurrency/Task``                         |
| `sSct`| ``_Concurrency/UnsafeCurrentTask``            |