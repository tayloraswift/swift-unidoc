extension SymbolRelationship
{
    @frozen public
    struct Membership:Equatable, Hashable, Sendable
    {
        public
        let source:UnifiedSymbolResolution
        public
        let target:UnifiedSymbolResolution
        public
        let origin:ScalarSymbolResolution?

        @inlinable public
        init(of source:UnifiedSymbolResolution,
            in target:UnifiedSymbolResolution,
            origin:ScalarSymbolResolution? = nil)
        {
            self.source = source
            self.target = target
            self.origin = origin
        }
    }
}
extension SymbolRelationship.Membership:CustomStringConvertible
{
    public
    var description:String
    {
        """
        (member: \(self.source), of: \(self.target))
        """
    }
}
