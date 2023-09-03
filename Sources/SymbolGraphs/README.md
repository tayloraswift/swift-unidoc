# ``SymbolGraphs``

Defines the stable symbol graph ABI, which consists of its BSON schema and the underlying markdown ABI.

We track ABI versions with a ``MinorVersion`` tuple. Additive changes increment the minor version component, breaking changes increment the major version component. (Patch versions are not really meaningful for binary interfaces, so ABI versions don’t have a patch component.)

Please check if you need to update the version tuple in <file:ABI.swift> when changing any of the following modules:

-   ``MarkdownABI``
-   ``MarkdownSemantics``
-   ``MarkdownAST``
-   ``SymbolGraphs``
-   ``SymbolGraphCompiler``
-   ``SymbolGraphLinker``
-   ``SymbolGraphParts``
