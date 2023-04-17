extension SymbolRelationship
{
    @frozen public
    struct Inheritance:SuperformRelationship, Equatable, Hashable, Sendable
    {
        public
        let source:ScalarSymbolResolution
        public
        let target:ScalarSymbolResolution
        public
        let origin:ScalarSymbolResolution?

        @inlinable public
        init(by source:ScalarSymbolResolution,
            of target:ScalarSymbolResolution,
            origin:ScalarSymbolResolution? = nil)
        {
            self.source = source
            self.target = target
            self.origin = origin
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
