extension SymbolRelationship
{
    @frozen public
    struct Inheritance:SuperformRelationship, Equatable, Hashable, Sendable
    {
        public
        let source:ScalarSymbolResolution
        public
        let target:ScalarSymbolResolution

        @inlinable public
        init(by source:ScalarSymbolResolution,
            of target:ScalarSymbolResolution)
        {
            self.source = source
            self.target = target
        }
    }
}
extension SymbolRelationship.Inheritance:CustomStringConvertible
{
    public
    var description:String
    {
        """
        (inheritance by: \(self.source), of: \(self.target))
        """
    }
}
