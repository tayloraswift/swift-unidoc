import MarkdownABI

extension Markdown {
    public final class BlockItem: BlockContainer<BlockElement> {
        public var checkbox: Checkbox?

        @inlinable public init(checkbox: Checkbox? = nil, elements: [BlockElement]) {
            self.checkbox = checkbox
            super.init(elements)
        }

        /// Emits an `li` element.
        public override func emit(into binary: inout Markdown.BinaryEncoder) {
            binary[.li] {
                self.checkbox?.emit(into: &$0)
                super.emit(into: &$0)
            }
        }
    }
}
