extension SymbolGraph.Culture
{
    @frozen public
    struct Reexports:Equatable, Sendable
    {
        public
        var unhashed:[Int32]
        public
        var hashed:[Int32]

        @inlinable public
        init(unhashed:[Int32] = [], hashed:[Int32] = [])
        {
            self.unhashed = unhashed
            self.hashed = hashed
        }
    }
}
