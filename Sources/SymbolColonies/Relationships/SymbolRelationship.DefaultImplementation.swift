extension SymbolRelationship
{
    @frozen public
    struct DefaultImplementation:Equatable, Hashable, Sendable
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
