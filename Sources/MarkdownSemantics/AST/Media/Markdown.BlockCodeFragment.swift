import Sources
import Symbols

extension Markdown {
    /// A `BlockCodeFragment` models a code snippet (`@Snippet`) that is embedded in the
    /// documentation.
    ///
    /// It is tempting to consider `BlockCodeFragment` as a special case of
    /// ``BlockCodeReference`` (`@Code`). But there are important differences that merit a
    /// separation of the two types.
    ///
    /// 1.  `BlockCodeFragment` is always eagarly inlined, and can produce multiple blocks when
    ///     inlined. This is because snippets can contain captions, which are treated the same
    ///     as markup in the documentation itself.
    ///
    /// 1.  `BlockCodeFragment` cannot have AST children, because its children live in the
    ///     referenced snippet file.
    ///
    /// 1.  `BlockCodeFragment`s can only reference a fixed set of snippets that are known early
    ///     on during the documentation build process. Moreover, it can only reference code that
    ///     is written in Swift.
    ///
    /// 1.  `BlockCodeFragment` can contain fractional syntax, which implies that code
    ///     highlighting must be performed ahead of time.
    ///
    /// 1.  `BlockCodeFragment` does not support diffing.
    ///
    /// A `BlockCodeFragment` by itself is just a snippet and slice name. It is supposed to be
    /// broken up into ``BlockCodeLiteral`` elements that contain the actual code via the
    /// snippet inlining process.
    final class BlockCodeFragment: BlockLeaf {
        /// The name of the snippet, with no file extension.
        private var snippet: String?
        private(set) var slice: String?

        override init() {
            self.snippet = nil
            self.slice = nil

            super.init()
        }
    }
}
extension Markdown.BlockCodeFragment: Markdown.BlockDirectiveType {
    enum Option: String, Markdown.BlockDirectiveOption {
        case id
        case path
        case slice
    }

    func configure(option: Option, value: Markdown.SourceString) throws {
        let value: String = value.string
        switch option {
        case .slice:
            guard case nil = self.slice else {
                throw option.duplicate
            }

            self.slice = value

        //  This is a Unidoc extension, and is not actually part of SE-0356. But SE-0356 is
        //  really poorly written and the `path:` syntax is just awful.
        case .id:
            self.snippet = value

        case .path:
            //  We are going to ignore the first path component, which is the package name,
            //  for several reasons.
            //
            //  1.  It serves no purpose to qualify a snippet path with the package name,
            //      other than to accommodate a flawed implementation of Swift DocC.
            //
            //  2.  Package names are extrinsic to the documentation, and would need to be
            //      kept up-to-date with the package name in the `Package.swift`.
            //
            //  3.  Package names can contain URL-unfriendly characters, which would cause
            //      all of their snippets to become unusable. Therefore, DocC `path:`
            //      syntax imposes an additional limitation on package names that is not
            //      legitimized anywhere else.
            guard
            let i: String.Index = value.firstIndex(of: "/"),
            let j: String.Index = value.lastIndex(of: "/") else {
                throw PathError.format(value)
            }

            //  OK for the path to contain additional intermediate path components, which
            //  are just as irrelevant as the package name, because snippet names are
            //  unique within a package.
            switch value[value.index(after: i)...].prefix(while: { $0 != "/" }) {
            case "Snippets":
                self.snippet = String.init(value[value.index(after: j)...])

            case let invalid:
                throw PathError.directory(String.init(invalid))
            }
        }
    }
}
extension Markdown.BlockCodeFragment {
    /// We currently always eagarly inline snippet slices, which simplifies the rendering model.
    ///
    /// As long as people are not reusing the same slices in multiple places, this has no
    /// performance drawbacks. No one should be doing that (extensively) anyways, because that
    /// would result in documentation that is hard to browse.
    func inline(
        snippets: [String: Markdown.Snippet],
        into yield: (consuming Markdown.BlockElement) -> ()
    ) throws {
        guard
        let snippet: String = self.snippet,
        let snippet: Markdown.Snippet = snippets[snippet] else {
            throw ReferenceError.snippet(
                undefined: self.snippet,
                available: snippets.keys.sorted()
            )
        }

        if  let slice: String = self.slice {
            //  If this is the first slice, we should also inline the caption.
            if  case slice? = snippet.slices.keys.first {
                for block: Markdown.BlockElement in snippet.caption() {
                    yield(block)
                }
            }

            if  let slice: Markdown.SnippetSlice<Symbol.USR> = snippet.slices[slice] {
                yield(
                    Markdown.BlockCodeLiteral.init(
                        utf8: slice.utf8,
                        code: slice.code,
                        location: slice.location(in: snippet.id)
                    )
                )
            } else {
                throw ReferenceError.slice(
                    undefined: slice,
                    available: snippet.slices.keys.elements
                )
            }
        } else {
            //  Snippet captions cannot contain topics, so we can just add them directly to
            //  the ``blocks`` list.
            for block: Markdown.BlockElement in snippet.caption() {
                yield(block)
            }
            for slice: Markdown.SnippetSlice<Symbol.USR> in snippet.slices.values {
                yield(
                    Markdown.BlockCodeLiteral.init(
                        utf8: slice.utf8,
                        code: slice.code,
                        location: slice.location(in: snippet.id)
                    )
                )
            }
        }
    }
}
