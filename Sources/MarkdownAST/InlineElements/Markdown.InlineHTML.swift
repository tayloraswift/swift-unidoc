extension Markdown {
    @frozen public struct InlineHTML: Equatable, Hashable, Sendable {
        public var text: String

        @inlinable public init(text: String) {
            self.text = text
        }
    }
}
extension Markdown.InlineHTML: Markdown.TreeElement {
    /// Emits the raw text content of this element in a transparent instruction context.
    public func emit(into binary: inout Markdown.BinaryEncoder) {
        binary[.transparent] = self.text
    }
}
