# Getting started

This article demonstrates how to link to documentation in other modules.

Here is an external link to wikipedia: [Wikipedia](https://en.wikipedia.org/wiki/Main_Page)

Here is an external link in autolink form: <https://en.wikipedia.org/wiki/Main_Page>

## Codelinks

You can link to a module with a codelink: ``BarbieCore``.

You can link to a declaration with a codelink: ``Barbie.ID``.

You can link to modules from other packages/frameworks that are dependencies of the current
module: ``_Concurrency``.

You can link to declarations from other packages/frameworks that are dependencies of the current
module: ``Task``.

You can also link to nested declarations from other packages/frameworks, such as
``AsyncStream.Continuation.yield(_:)``.

## Doclinks

You can link to a module with a doclink: <doc:BarbieCore>.

You can link to a declaration with a doclink: <doc:Barbie.ID>.

You can link to modules from other packages/frameworks that are dependencies of the current
module: <doc:_Concurrency>.

You can link to declarations from other packages/frameworks that are dependencies of the current
module: <doc:Task>.

You can also link to nested declarations from other packages/frameworks, such as
<doc:AsyncStream.Continuation.yield(_:)>.

## Relative hyperlinks

You can link to a module with a relative hyperlink. For example, [`BarbieCore`](./BarbieCore)
produces [`BarbieCore`](/BarbieCore).

You can link to a declaration with a relative hyperlink. For example,
[`Barbie.ID`](/Barbie/ID) produces [`Barbie.ID`](/Barbie/ID).

You can link to modules from other packages/frameworks that are dependencies of the current
module. For example, [`_Concurrency`](/_Concurrency) produces
[`_Concurrency`](/_Concurrency).

You can link to declarations from other packages/frameworks that are dependencies of the current
module. For example, [`Task`](/Task) produces [`Task`](/Task).

You can also link to nested declarations from other packages/frameworks, such as
[`yield`](/AsyncStream/Continuation/yield(_:)).

## Snippets

@Snippet(id: "GettingStarted", slice: "")

@Snippet(id: "GettingStarted", slice: "F1")

@Snippet(id: "GettingStarted", slice: "F2")
