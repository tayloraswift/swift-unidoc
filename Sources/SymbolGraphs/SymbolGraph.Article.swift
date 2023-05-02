import Codelinks
import MarkdownABI

extension SymbolGraph
{
    @frozen public
    struct Article<Link>:Equatable, Sendable where Link:Equatable & Sendable
    {
        public
        let overview:MarkdownBytecode
        public
        let details:MarkdownBytecode
        public
        let links:[Link]
        public
        let fold:Int

        @inlinable public
        init(overview:MarkdownBytecode, details:MarkdownBytecode, links:[Link], fold:Int)
        {
            self.overview = overview
            self.details = details
            self.links = links
            self.fold = fold
        }
    }
}
