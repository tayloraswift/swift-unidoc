import MarkdownABI

extension Markdown {
    public final class BlockListUnordered: BlockContainer<BlockItem> {
        /// Emits a `ul` element.
        public override func emit(into binary: inout Markdown.BinaryEncoder) {
            binary[.ul] { super.emit(into: &$0) }
        }
    }
}
