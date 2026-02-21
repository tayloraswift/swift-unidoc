import MarkdownABI

extension Markdown {
    public final class BlockHTML: BlockElement {
        public var text: String

        @inlinable public init(text: String) {
            self.text = text
        }

        /// Emits the raw text content of this element in a transparent instruction context.
        public override func emit(into binary: inout Markdown.BinaryEncoder) {
            binary[.transparent] = self.text
        }
    }
}
