extension SymbolGraph
{
    @frozen public
    struct Location:Equatable, Hashable, Sendable
    {
        public
        let position:Position
        public
        let file:UInt32

        @inlinable public
        init(position:Position, file:UInt32)
        {
            self.position = position
            self.file = file
        }
    }
}
