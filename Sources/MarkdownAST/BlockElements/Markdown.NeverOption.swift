extension Markdown {
    @frozen public enum NeverOption: BlockDirectiveOption {
        @inlinable public init?(rawValue: String) { nil }

        @inlinable public var rawValue: String { fatalError() }
    }
}
