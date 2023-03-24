extension SymbolRelationship
{
    @frozen public
    struct Requirement:Equatable, Hashable, Sendable
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
extension SymbolRelationship.Requirement:CustomStringConvertible
{
    public
    var description:String
    {
        """
        (requirement: \(self.source), of: \(self.target))
        """
    }
}
