import MarkdownABI

extension Markdown {
    @frozen public struct InlineImage: Equatable, Hashable, Sendable {
        public var elements: [InlineSpan]
        public var target: Outlinable<Markdown.SourceString>?
        public var title: String?

        @inlinable public init(
            elements: [InlineSpan] = [],
            target: Outlinable<Markdown.SourceString>?,
            title: String? = nil
        ) {
            self.elements = elements
            self.target = target
            self.title = title
        }
    }
}
extension Markdown.InlineImage: Markdown.TreeElement {
    public func emit(into binary: inout Markdown.BinaryEncoder) {
        binary[.img] {
            $0[.alt] = self.alt
            $0[.src] = self.target
            $0[.title] = self.title
        }
    }

    @inlinable public mutating func outline(
        by register: (Markdown.AnyReference) throws -> Int?
    ) rethrows {
        if  case .inline(let expression) = self.target,
            case let reference? = try register(.filePath(expression)) {
            self.target = .outlined(reference)
        }
    }
}
extension Markdown.InlineImage: Markdown.TextElement {
    @inlinable public static func += (text: inout String, self: Self) {
        for element: Markdown.InlineSpan in self.elements {
            text += element
        }
    }
}
extension Markdown.InlineImage {
    /// Returns ``text`` if it is not empty.
    @inlinable public var alt: String? {
        let alt: String = self.text
        return alt.isEmpty ? nil : alt
    }
}
