extension SymbolRelationship
{
    @frozen public
    struct OptionalRequirement:Equatable, Hashable, Sendable
    {
        public
        let source:ScalarSymbolResolution
        public
        let target:ScalarSymbolResolution

        @inlinable public
        init(_ source:ScalarSymbolResolution,
            of target:ScalarSymbolResolution)
        {
            self.source = source
            self.target = target
        }
    }
}
