import Codelinks

extension SymbolGraph
{
    @frozen public
    struct Article<Link>:Equatable, Sendable where Link:Equatable & Sendable
    {
        public
        let markdown:[UInt8]
        public
        let links:[Link]
        public
        let fold:Int

        @inlinable public
        init(markdown:[UInt8], links:[Link], fold:Int)
        {
            self.markdown = markdown
            self.links = links
            self.fold = fold
        }
    }
}
