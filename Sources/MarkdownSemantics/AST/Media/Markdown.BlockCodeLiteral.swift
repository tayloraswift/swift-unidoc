import MarkdownABI
import Sources
import Symbols

extension Markdown {
    /// A `BlockCodeLiteral` is like a ``BlockCode``, but it contains code that has already been
    /// highlighted and compiled to bytecode.
    final class BlockCodeLiteral: BlockElement {
        private let language: String
        private let utf8: [UInt8]
        private var code: [Markdown.SnippetFragment<Outlinable<Symbol.USR>>]
        private var location: Outlinable<SourceLocation<Int32>>?

        private init(
            language: String,
            utf8: [UInt8],
            code: [Markdown.SnippetFragment<Outlinable<Symbol.USR>>],
            location: Outlinable<SourceLocation<Int32>>?
        ) {
            self.language = language
            self.utf8 = utf8
            self.code = code
            self.location = location
        }

        override func emit(into binary: inout Markdown.BinaryEncoder) {
            binary[.snippet, { $0[.language] = self.language }] {
                for fragment: Markdown.SnippetFragment<Outlinable<Symbol.USR>> in self.code {
                    if  let color: Markdown.Bytecode.Context = fragment.color {
                        $0[color, { $0[.href] = fragment.usr?.outlined }] {
                            $0 += self.utf8[fragment.range]
                        }
                    } else if
                        let reference: Int = fragment.usr?.outlined {
                        $0[.a, { $0[.href] = reference }] {
                            $0 += self.utf8[fragment.range]
                        }
                    } else {
                        $0 += self.utf8[fragment.range]
                    }
                }
            }
            if  case .outlined(let reference) = self.location {
                binary &= reference
            }
        }

        override func outline(by register: (Markdown.AnyReference) throws -> Int?) rethrows {
            if  case .inline(let location) = self.location,
                let reference: Int = try register(.location(location)) {
                self.location = .outlined(reference)
            }

            for i: Int in self.code.indices {
                try {
                    if  case .inline(let usr)? = $0.usr,
                        let reference: Int = try register(.symbolic(usr: usr)) {
                        $0.usr = .outlined(reference)
                    }
                } (&self.code[i])
            }

            try super.outline(by: register)
        }
    }
}
extension Markdown.BlockCodeLiteral {
    convenience init(
        language: String = "swift",
        utf8: [UInt8],
        code: borrowing [Markdown.SnippetFragment<Symbol.USR>],
        location: SourceLocation<Int32>?
    ) {
        self.init(
            language: language,
            utf8: utf8,
            code: code.map {
                .init(
                    range: $0.range,
                    color: $0.color,
                    usr: $0.usr.map(Markdown.Outlinable.inline(_:))
                )
            },
            location: location.map(Markdown.Outlinable.inline(_:))
        )
    }
}
