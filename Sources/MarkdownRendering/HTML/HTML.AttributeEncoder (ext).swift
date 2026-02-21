import HTML

extension HTML.AttributeEncoder {
    @inlinable public var highlight: Markdown.SyntaxHighlight? {
        get {
            nil
        }
        set(value) {
            self.class = value?.description
        }
    }
}
