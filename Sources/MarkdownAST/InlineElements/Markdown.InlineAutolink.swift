import Sources

extension Markdown {
    @frozen public struct InlineAutolink: Equatable {
        public let text: SourceString
        /// Indicates if this autolink originated from an inline code span.
        public let code: Bool

        @inlinable init(text: SourceString, code: Bool) {
            self.text = text
            self.code = code
        }
    }
}
@available(*, deprecated)
extension Markdown.InlineAutolink: CustomStringConvertible {
    @inlinable public var description: String { [][0] }
}
extension Markdown.InlineAutolink {
    @inlinable public var source: SourceReference<Markdown.Source> {
        self.text.source
    }
}
extension Markdown.InlineAutolink {
    @inlinable public static func code(
        link text: String,
        at source: SourceReference<Markdown.Source>
    ) -> Self {
        .init(text: .init(source: source, string: text), code: true)
    }

    @inlinable public static func doc(
        link text: String,
        at source: SourceReference<Markdown.Source>
    ) -> Self {
        .init(text: .init(source: source, string: text), code: false)
    }
}
extension Markdown.InlineAutolink {
    @inlinable internal var element: Markdown.InlineElement {
        self.code ?
        .code(.init(text: self.text.string)) :
        .link(.init(source: self.source, url: self.text.string))
    }
}
