import MarkdownAST
import Sources

extension Markdown {
    final class BlockDivision: Markdown.BlockContainer<Markdown.BlockElement> {
        var source: SourceReference<Markdown.Source>?

        private(set) var size: Int?

        init() {
            self.source = nil
            self.size = nil
            super.init([])
        }

        override func emit(into binary: inout Markdown.BinaryEncoder) {
            binary[.div] {
                $0[.style] = self.size.map { "grid-column: span \($0);" }
            } content: {
                super.emit(into: &$0)
            }
        }
    }
}
extension Markdown.BlockDivision: Markdown.BlockDirectiveType {
    enum Option: String, Markdown.BlockDirectiveOption {
        case size
    }

    public final func configure(option: Option, value: Markdown.SourceString) throws {
        switch option {
        case .size:
            guard case nil = self.size else {
                throw option.duplicate
            }

            self.size = try option.cast(value, to: Int.self)
        }
    }
}
