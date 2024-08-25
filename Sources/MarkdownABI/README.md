# ``/MarkdownABI``

This module defines the markdown bytecode ABI.

Markdown bytecode gets its name because it was originally conceived as an efficient serialization format for markdown documents. But over time, it proved to be so useful that we now use it as a general-purpose rich text serialization format.

Markdown bytecode has a lot of features that are tailored towards Swift documentation, and literature that is related to programming in general. However, we have generally tried to keep higher-level concepts out of the ABI itself.

Markdown bytecode cannot represent the entire HTML specification, but almost all of the HTML we store today goes through bytecode in some way.


## How does it work?

Markdown bytecode is a superset of UTF-8. It stores raw text in unescaped form, and it is possible to copy UTF-8 directly into a bytecode string. This also means it is often possible to inspect bytecode strings and see the raw UTF-8 embedded inside them. It is also possible (but not necessarily straightforward) to efficiently render bytecode strings to plain text. This avoids the need to store multiple representations of the same text.


## Key concepts

Most of the content of a bytecode string that is not UTF-8 text consists of either **codewords** or **references**.

**Codewords** are fixed-length sequences that represent HTML elements or attributes. The ABI assigns stable meanings to codewords. Some codewords are shorthands for complex markup patterns that appear frequently in programming contexts, such as syntax highlights.

**References** are variable-length sequences that encode ``Int``egers. The ABI does not assign any meaning to references, instead they provide the means of building higher-level abstractions on top of the ABI. The variable-length encoding is most efficient for small positive integers, and least efficient for large positive integers and negative integers. Therefore, it is usually advantageous to use reference encodings that occupy small positive integers.

Codewords and references can contain valid UTF-8 sequences. Therefore, they are delimited by non-unicode bytes called **markers**.


## Topics

### Namespaces

-   ``Markdown``

### Attributes

-   ``Markdown.AttributeEncoder``
-   ``Markdown.Bytecode.Attribute``

### Elements

-   ``Markdown.BinaryEncoder``
-   ``Markdown.Bytecode.Context``
-   ``Markdown.Bytecode.Emission``

### Bytecode and interpretation

-   ``Markdown.Bytecode``
-   ``Markdown.Bytecode.Marker``
-   ``Markdown.Bytecode.Emission``
-   ``Markdown.BinaryDecoder``
-   ``Markdown.Instruction``

### Plugins and extensions

-   ``Markdown.CodeHighlighter``
-   ``Markdown.CodeLanguage``
-   ``Markdown.CodeLanguageType``
-   ``Markdown.DiffType``
-   ``Markdown.PlainText``
-   ``Markdown.PlainText.Highlighter``
