import MarkdownABI

extension Markdown {
    @frozen public enum InlineSpan: Equatable, Hashable, Sendable {
        case container(InlineContainer<Self>)
        case code(InlineCode)
        case html(InlineHTML)
        case text(String)
    }
}
extension Markdown.InlineSpan: Markdown.TreeElement {
    @inlinable public func emit(into binary: inout Markdown.BinaryEncoder) {
        switch self {
        case .container(let container):
            container.emit(into: &binary)

        case .code(let code):
            code.emit(into: &binary)

        case .html(let html):
            html.emit(into: &binary)

        case .text(let unescaped):
            binary += unescaped
        }
    }
}
extension Markdown.InlineSpan: Markdown.TextElement {
    @inlinable public static func += (text: inout String, self: Self) {
        switch self {
        case .container(let container): text += container
        case .code(let code):           text += code
        case .html:                     return
        case .text(let part):           text += part
        }
    }
}
