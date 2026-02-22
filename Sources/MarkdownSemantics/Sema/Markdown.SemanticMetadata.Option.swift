extension Markdown.SemanticMetadata {
    @frozen public struct Option<Value> {
        public var value: Value
        public var scope: OptionScope

        @inlinable public init(value: Value, scope: OptionScope = .local) {
            self.value = value
            self.scope = scope
        }
    }
}
