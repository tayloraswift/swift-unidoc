import MarkdownABI

extension Markdown {
    @frozen public struct SnippetFragment<USR> {
        public let range: Range<Int>
        public var color: Bytecode.Context?
        public var usr: USR?

        @inlinable public init(range: Range<Int>, color: Bytecode.Context?, usr: USR?) {
            self.range = range
            self.color = color
            self.usr = usr
        }
    }
}
