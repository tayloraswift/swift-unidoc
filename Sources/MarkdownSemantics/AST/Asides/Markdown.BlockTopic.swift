import MarkdownABI
import MarkdownAST
import MarkdownDisplay

extension Markdown {
    public final class BlockTopic: BlockElement {
        public private(set) var items: [Outlinable<InlineAutolink>]

        private init(items: [Outlinable<InlineAutolink>]) {
            self.items = items
        }

        public override func emit(into binary: inout Markdown.BinaryEncoder) {
            binary[.ul, { $0[.class] = "cards" }] {
                for item: Outlinable<InlineAutolink> in self.items {
                    $0[.li] {
                        switch item {
                        case .outlined(let reference):
                            $0 &= .card(reference)

                        case .inline(let autolink):
                            $0[.code] = autolink.text.string
                        }
                    }
                }
            }
        }

        public override func outline(
            by register: (Markdown.AnyReference) throws -> Int?
        ) rethrows {
            for i: Int in self.items.indices {
                try {
                    if  case .inline(let autolink) = $0,
                        case let reference? = try register(.init(autolink)) {
                        $0 = .outlined(reference)
                    }
                } (&self.items[i])
            }

            try super.outline(by: register)
        }
    }
}
extension Markdown.BlockTopic {
    convenience init?(from list: __shared Markdown.BlockListUnordered) {
        var promoted: [Markdown.Outlinable<Markdown.InlineAutolink>] = []

        for item: Markdown.BlockItem in list.elements {
            if  item.elements.count == 1,
                case let paragraph as Markdown.BlockParagraph = item.elements[0],
                paragraph.elements.count == 1,
                case .autolink(let autolink) = paragraph.elements[0] {
                promoted.append(.inline(autolink))
            } else {
                return nil
            }
        }

        if  promoted.isEmpty {
            return nil
        }

        self.init(items: promoted)
    }
}
