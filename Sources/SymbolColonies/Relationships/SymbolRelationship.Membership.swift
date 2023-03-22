extension SymbolRelationship
{
    @frozen public
    struct Membership:Equatable, Hashable, Sendable
    {
        public
        let source:UnifiedSymbolResolution
        public
        let target:UnifiedSymbolResolution

        @inlinable public
        init(of source:UnifiedSymbolResolution,
            in target:UnifiedSymbolResolution)
        {
            self.source = source
            self.target = target
        }
    }
}
