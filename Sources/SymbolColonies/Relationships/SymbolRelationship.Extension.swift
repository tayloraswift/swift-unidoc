extension SymbolRelationship
{
    @frozen public
    struct Extension:Equatable, Hashable, Sendable
    {
        public
        let source:BlockSymbolResolution
        public
        let target:ScalarSymbolResolution

        @inlinable public
        init(_ source:BlockSymbolResolution,
            of target:ScalarSymbolResolution)
        {
            self.source = source
            self.target = target
        }
    }
}
