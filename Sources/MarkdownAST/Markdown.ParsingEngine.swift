import Sources

extension Markdown {
    public protocol ParsingEngine {
        func parse(
            _ source: borrowing Source,
            onError: (any Error, SourceReference<Source>) -> ()
        ) -> [BlockElement]
    }
}
extension Markdown.ParsingEngine {
    /// Parses some markdown, ignoring all errors.
    @inlinable public func parse(
        _ source: borrowing Markdown.Source
    ) -> [Markdown.BlockElement] {
        self.parse(source) { _, _ in }
    }
}
