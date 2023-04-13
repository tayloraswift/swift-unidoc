extension SymbolRelationship
{
    @frozen public
    struct DefaultImplementation:SuperformRelationship, Equatable, Hashable, Sendable
    {
        public
        let source:ScalarSymbolResolution
        public
        let target:ScalarSymbolResolution
        public
        let origin:ScalarSymbolResolution?

        @inlinable public
        init(_ source:ScalarSymbolResolution,
            of target:ScalarSymbolResolution,
            origin:ScalarSymbolResolution? = nil)
        {
            self.source = source
            self.target = target
            self.origin = origin
        }
    }
}
extension SymbolRelationship.DefaultImplementation:CustomStringConvertible
{
    public
    var description:String
    {
        """
        (default implementation: \(self.source), of: \(self.target))
        """
    }
}
