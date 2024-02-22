import Sources

extension SymbolGraph.Outline
{
    @frozen public
    struct Unresolved:Equatable, Hashable, Sendable
    {
        public
        let link:String
        public
        let type:LinkType
        public
        let location:SourceLocation<Int32>?

        @inlinable
        init(link:String, type:LinkType, location:SourceLocation<Int32>?)
        {
            self.link = link
            self.type = type
            self.location = location
        }
    }
}
