import MarkdownABI

extension Markdown {
    public final class BlockRule: BlockElement {
        /// Emits an `hr` element.
        public override func emit(into binary: inout Markdown.BinaryEncoder) {
            binary[.hr]
        }
    }
}
