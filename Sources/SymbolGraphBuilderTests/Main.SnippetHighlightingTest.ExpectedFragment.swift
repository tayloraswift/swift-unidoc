#if canImport(IndexStoreDB)

import MarkdownABI
import Symbols

extension Main.SnippetHighlightingTest {
    struct ExpectedFragment: Equatable {
        let token: String
        let color: Markdown.Bytecode.Context?
        let usr: Symbol.USR?

        init(
            token: String,
            color: Markdown.Bytecode.Context? = nil,
            usr: Symbol.USR? = nil
        ) {
            self.token = token
            self.color = color
            self.usr = usr
        }
    }
}

#endif
