extension SymbolGraph
{
    @frozen public
    struct SourceLocation
    {
        public
        let position:SourcePosition
        public
        let file:UInt32

        @inlinable public
        init(position:SourcePosition, file:UInt32)
        {
            self.position = position
            self.file = file
        }
    }
}
