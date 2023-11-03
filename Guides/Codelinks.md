# Unified codelinks

- author: **@tayloraswift**
- status: **implemented in unidoc 0.3.14**

This document describes the design of the unified codelink format.

## Motivation

There are lots of different codelink formats currently in use across the Swift ecosystem, including the current Unidoc codelink format. Many of these formats are incompatible with each other.

Although the Unidoc format provides many features unavailable in DocC, developers are sometimes [reluctant](https://github.com/karwa/swift-url/pull/180) to use it because it is not compatible with DocC. Recent changes to the DocC codelink format have resolved some of the issues that originally motivated a different syntax, which makes it possible for us to design a unified codelink format that is more compatible with DocC.

## Overview of existing formats

### DocC symbol links

DocC uses the term *symbol link* to refer to what we call *codelinks*.

DocC symbol links are encapsulated with two backticks, and use the `/` character as the path separator. Here are some examples of DocC symbol links:

```
/// ``Int``
/// ``Array/count``
/// ``Unicode/Scalar``
```

DocC symbol links resemble URLs, and many aspects of their design were once motivated by the desire to make them usable as URLs. One consequence of this is that the original DocC symbol link format was [case-insensitive](https://forums.swift.org/t/why-the-case-insensitive-symbols-in-docc/53175) with respect to disambiguation. (DocC symbol link casing must still match the original symbol casing.)

URL-symbol link equivalence was eventually abandoned, and the DocC symbol link format was declared by fiat to be fully case-sensitive around 2022. The DocC format is unversioned, so this ended up creating even more confusion about the behavior of DocC symbol links.

#### Codelink disambiguation

DocC symbol links can be disambiguated by phylum or by symbol hash. Valid DocC phyla are:

1.  `swift.associatedtype`
1.  `swift.enum`
1.  `swift.enum.case`
1.  `swift.class`
1.  `swift.func`
1.  `swift.func.op`
1.  `swift.var`
1.  `swift.deinit`
1.  `swift.init`
1.  `swift.method`
1.  `swift.property`
1.  `swift.subscript`
1.  `swift.macro`
1.  `swift.protocol`
1.  `swift.struct`
1.  `swift.typealias`
1.  `swift.type.method`
1.  `swift.type.property`
1.  `swift.type.subscript`

Symbol hashes are 24-bit integers obtained by applying a bespoke variant of the [FNV-1](https://en.wikipedia.org/wiki/Fowler%E2%80%93Noll%E2%80%93Vo_hash_function) hash function to the symbol’s ABI name. They are conventially written in lowercase base-36 without leading zeros.

It is theoretically possible for a hash to resemble a string such as `func`. Therefore, the `swift.` prefix is not redundant, but necessary to distinguish a hash from a phylum.

It is theoretically possible for a symbol link to use both disambiguation mechanisms, although this is almost never needed, because the hash disambiguator is almost always sufficient on its own.

DocC symbol links use the `-` character to denote the beginning of a disambiguation suffix. This was originally motivated by the desire to make symbol links usable as URLs, but makes the parsing of DocC symbol links challenging.

```
/// ``Sequence-swift.protocol``
/// ``Sequence/joined(separator:)-7w47r``
/// ``Sequence/joined(separator:)-swift.func-7w47r``
```

When encoded in URLs, this format composes badly with other URL features such as trailing slashes, and can create ambiguity of its own because `-` is also a valid Swift operator character.


#### Codelink vectors

DocC symbol links have no support for link vectors. When successfully resolved, only the final component appears in the rendered documentation. Documentation writers often work around this limitation by concatenating multiple symbol links together, which is cumbersome and error-prone.

```
/// ``Unicode`` `.` ``Unicode/Scalar`` `.` ``Unicode/Scalar/value``
```

#### Codelink namespacing

DocC symbol link namespacing is explicit and denoted by a leading slash, which is followed by a module name.

```
/// ``/Swift/Int``
```

While this simplifies the symbol resolution algorithm, it can create fragility when developers move symbols between modules, or rename modules. It is also inconsistent with the implicit namespacing used in Swift source code.

Developers sometimes mistakenly qualify symbol links with the wrong module name, which is particularly common when modules re-export symbols from other modules, or when the module is a “hidden” module such as [``_Concurrency``](https://swiftinit.org/docs/swift/_concurrency).


### Unidoc codelinks

Because this document proposes a new Unidoc codelink format, we will refer to the existing Unidoc codelink format as the *V3 format*.

Like DocC codelinks, Unidoc V3 codelinks are encapsulated with two backticks, but they use the `.` character as the path separator. Here are some examples of Unidoc codelinks:

```
/// ``Int``
/// ``Array.count``
/// ``Unicode.Scalar``
```

Unidoc codelinks were designed without any consideration for URLs, and were intended to match the lexical format of Swift source identifiers as closely as possible.

Using `.` avoids some of the parsing ambiguities inherent in the `/` path separator. For example, the DocC symbol link ` ``UInt128//==(_:_:)`` ` might refer to the tree entity `["UInt128", "==(_:_:)"]`, or it might refer to the tree entity `["UInt128", "/==(_:_:)"]`.

#### Codelink disambiguation

Like DocC symbol links, Unidoc V3 codelinks can be disambiguated by phylum or by symbol hash.

Phylum disambiguation is denoted by prefixing the symbol name with swift keywords. Some examples include:

```
/// ``struct Int``
/// ``var Array.count``
/// ``static var Int.bitWidth``
```

This format is extremely handy when disambiguating enum cases, but it suffers from nasty edge cases when mixed with vector syntax. It also implies some strange syntax for subscripts, for example, ` ``class Foo.Bar.subscript(_:)`` `.

Unidoc V3 symbol hashes appear in brackets at the end of the codelink. For example:

```
/// ``Sequence.joined(separator:) [7W47R]``
```

The base-36 digits are case-insensitive.

#### Codelink vectors

All Unidoc V3 codelinks are vectors by default. Therefore, when you write ` ``Unicode.Scalar`` `, you actually get the vector `["Unicode", "Scalar"]`. Since this is not always desirable, Unidoc V3 codelinks allow you to trim leading components from the vector by using the space character (` `) as a path separator.

```
/// ``Dictionary Keys.contains(_:)``
```

This causes problems when combined with phylum disambiguation, because the hidden component can resemble a keyword. For example, ` ``struct Int`` ` might refer to a struct named `Int`, or it might refer to a nested declaration named `Int` inside a type named `struct`.

To address this problem, Unidoc V3 codelinks use backticks to escape keywords. For example,

```
``struct Int``
```

refers to a struct named `Int`, while

```
`` `struct` Int``
```

refers to a declaration named `Int` inside a type named `struct`.

This syntax confuses markdown parsers, and is difficult to read. It also introduces some subtle inconsistencies with the way some contextual keywords such as `actor` behave in source code. The consequence of all this is a syntax that is deceptively intuitive, but is actually incredibly complex and hard to understand.

#### Codelink namespacing

Unidoc codelink namespacing is implicit, and behaves similarly to namespacing in Swift source code. For example, ` ``Int`` ` can refer to the `Int` type in the current module, while ` ``Swift.Int`` ` refers to the `Int` type in the `Swift` module. However, if there is no type named `Int` in the current module, then ` ``Int`` ` itself can be used to reference the standard library `Int` type.

Namespaces are module-level. Any module that is a dependency (direct or indirect) of the current module can contribute symbols to the current module’s namespace.

As in source code, there is no way to reference a module with the same name as a type in the current module.

### Swiftinit URL format

The [Swiftinit](https://swiftinit.org) URL format is a DocC-like link format that uses the `.` character to discriminate the letter case of the final path component. This allows the format to be case-insensitive, while reducing the frequency of path collisions. Accordingly, Swiftinit can assign paths such as `/dictionary/keys` and `/dictionary.keys` to symbols that would otherwise require disambiguation.

Swiftinit hashes appear as query parameters; therefore the DocC symbol link ` ``Sequence/joined(separator:)-7w47r`` ` would be roughly equivalent to `/sequence.joined(separator:)?hash=7W47R ` in the Swiftinit URL format. The Swiftinit URL format otherwise behaves similarly to the DocC symbol link format.


## Proposed unified codelink format

The proposed unified codelink format is a superset of the DocC symbol link format. This allows developers to incrementally adopt advanced features while reducing the amount of reformatting needed to upgrade existing documentation.


### Case sensitive

The unified codelink format is case-sensitive. This is consistent with the behavior of Swift identifiers, and helps us avoid the complexity of a case-insensitive grammar.

### Path separator

The unified codelink format uses the `.` character to join vector links. The `/` character is also a valid path separator, but only components that appear after the last `/` will appear in the rendered documentation. This means that prior to the last `/`, the two path separators are interchangeable.

| Codelink | Renders as |
| --- | --- |
| ` ``Unicode.Scalar.value`` ` | `Unicode.Scalar.value` |
| ` ``Unicode/Scalar.value`` ` | `Scalar.value` |
| ` ``Unicode.Scalar/value`` ` | `value` |
| ` ``Unicode/Scalar/value`` ` | `value` |

Trailing slashes are forbidden.

Multiple consecutive path separators are forbidden. This prevents ambiguity with custom operators.

| Codelink | Renders as | Parses as |
| --- | --- | --- |
| ` ``Real...(_:_:)`` ` | `Real...(_:_:)` | `["Real", "..(_:_:)"]` |
| ` ``Real/..(_:_:)`` ` | `..(_:_:)` | `["Real", "..(_:_:)"]` |
| ` ``Real....(_:_:)`` ` | `Real....(_:_:)` | `["Real", "...(_:_:)"]` |
| ` ``Real/...(_:_:)`` ` | `...(_:_:)` | `["Real", "...(_:_:)"]` |
| ` ``Real./(_:_:)`` ` | `Real./(_:_:)` | `["Real", "/(_:_:)"]` |
| ` ``Real//(_:_:)`` ` | `/(_:_:)` | `["Real", "/(_:_:)"]` |

If a path component begins with an operator character, all subsequent `.` characters are treated as part of the operator name.

| Codelink | Renders as | Parses as |
| --- | --- | --- |
| ` ``Real../.(_:_:)`` ` | `Real../.(_:_:)` | `["Real", "./.(_:_:)"]` |
| ` ``Real/./.(_:_:)`` ` | `./.(_:_:)` | `["Real", "./.(_:_:)"]` |

### Disambiguators

The unified codelink format supports both phylum and hash disambiguators. Both disambiguators appear in brackets at the end of the codelink. To prevent ambiguity, the hash disambiguator is always written in uppercase base-36.

| Codelink | Disambiguator |
| --- | --- |
| ` ``Fake [struct]`` ` | `phylum = struct` |
| ` ``Fake [STRUCT]`` ` | `hash = STRUCT` |

The space before the opening bracket is mandatory. Spaces can appear inside the brackets, if the corresponding swift keyphrase contains a space.

| Codelink | Disambiguator |
| --- | --- |
| ` ``Fake.max [class var]`` ` | `phylum = class var` |
| ` ``Fake.subscript [class subscript]`` ` | `phylum = class subscript` |

All keywords must be present; the `[func]` disambiguator always selects a global or instance function, and never a class or static function. Similarly, you cannot use `[class]` to select a class member of any phylum, it will only ever match a non-actor class type.

The `[actor]` disambiguator is the only disambiguator that can match an actor type.

There is no disambiguator for operators; operators always use one of the `[func]` or `[static func]` disambiguators.

Backticks are never used to escape keywords. Therefore, in rare cases the `[subscript]`, `[deinit]`, or `[init]` disambiguators may be needed despite the keyword also appearing in the symbol name.

| Codelink | Disambiguator |
| --- | --- |
| ` ``Fake.subscript [subscript]`` ` | `phylum = subscript` |
| ` ``Fake.subscript [case]`` ` | `phylum = case` |
| ` ``Fake.init [init]`` ` | `phylum = init` |
| ` ``Fake.init [case]`` ` | `phylum = case` |

To aid searchability, the `[let]` disambiguator is forbidden; all such properties use the `[var]` disambiguator instead.

### Backwards compatibility

For backwards compatibility with DocC, the unified codelink format also supports hyphen-prefixed disambiguators.

The legacy disambiguators behave the same way they do in DocC. This means some legacy disambiguators express filters that do not exist among the modern disambiguators:

| Legacy disambiguator | Modern equivalent |
| --- | --- |
| `-swift.associatedtype` | `[associatedtype]` |
| `-swift.enum` | `[enum]` |
| `-swift.enum.case` | `[case]` |
| `-swift.class` | no equivalent |
| `-swift.func` | no equivalent |
| `-swift.func.op` | no equivalent |
| `-swift.var` | no equivalent |
| `-swift.deinit` | `[deinit]` |
| `-swift.init` | `[init]` |
| `-swift.method` | no equivalent |
| `-swift.property` | no equivalent |
| `-swift.subscript` | `[subscript]` |
| `-swift.macro` | `[macro]` |
| `-swift.protocol` | `[protocol]` |
| `-swift.struct` | `[struct]` |
| `-swift.typealias` | `[typealias]` |
| `-swift.type.method` | no equivalent |
| `-swift.type.property` | no equivalent |
| `-swift.type.subscript` | no equivalent |

#### Unrelated disambiguators

For arcane historical reasons, XCode sometimes autofills interior path components with disambiguators. Today, this behavior is indistinguishable from a bug, but for backwards compatibility, the unified codelink format accepts and **ignores** all such disambiguators, as long as the next path component uses the `/` path separator.

| Codelink | Allowed? |
| --- | --- |
| ` ``Sloth-swift.struct/color`` ` | yes |
| ` ``Sloth-swift.struct.color`` ` | no |

#### Trailing parentheses

The unified codelink format always **ignores** empty trailing parentheses. This means it is possible to refer to a property named `x` with a codelink spelled ` ``x()`` `, even though it could never be called that way in source code.

### Namespacing

The unified codelink format uses implicit namespacing, and behaves similarly to namespacing in Swift source code. However, unlike Swift source code, it also supports explicit namespacing using the `/` prefix.

A `/` character followed by a single identifier is treated as a module name, and resolves to module-level documentation, if any exists.

A unified codelink cannot start with multiple consecutive `/` characters. It is possible to force the appearance of the module name in a vector link by using the `.` separator.

| Codelink | Renders as |
| --- | --- |
| ` ``/Swift/Int`` ` | `Int` |
| ` ``/Swift.Int`` ` | `Swift.Int` |

## Future directions

### Codelinks to overload families

There is [some interest](https://forums.swift.org/t/improving-the-presentation-of-overloaded-symbols-in-swift-docc/67713) in enabling the codelink format to refer to an entire overload family, rather than a single declaration. This would obviate the need to use hashes in many situations.

We could extend the proposed codelink format to support an explicit syntax for referencing an overload family as a whole. For example, we could use the `*` character within disambiguation brackets.

```
/// ``Sequence.joined(separator:) [*]``
```
