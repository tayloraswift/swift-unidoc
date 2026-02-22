import MarkdownABI

extension Markdown {
    @frozen public struct InlineCode: Equatable, Hashable, Sendable {
        public var text: String

        @inlinable public init(text: String) {
            self.text = text
        }
    }
}
extension Markdown.InlineCode: Markdown.TreeElement {
    public func emit(into binary: inout Markdown.BinaryEncoder) {
        binary[.code] = self.text
    }
}
extension Markdown.InlineCode: Markdown.TextElement {
    @inlinable public static func += (text: inout String, self: Self) {
        text += self.text
    }
}
