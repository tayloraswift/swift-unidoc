extension Markdown {
    @frozen public struct AnyOption: Markdown.BlockDirectiveOption {
        public let rawValue: String

        @inlinable public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
}
