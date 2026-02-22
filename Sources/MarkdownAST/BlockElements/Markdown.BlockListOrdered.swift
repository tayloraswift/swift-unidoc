import MarkdownABI

extension Markdown {
    public final class BlockListOrdered: BlockContainer<BlockItem> {
        /// Emits an `ol` element.
        public override func emit(into binary: inout Markdown.BinaryEncoder) {
            binary[.ol] { super.emit(into: &$0) }
        }
    }
}
