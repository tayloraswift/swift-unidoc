extension SymbolRelationship
{
    @frozen public
    struct Requirement:Equatable, Hashable, Sendable
    {
        public
        let source:ScalarSymbolResolution
        public
        let target:ScalarSymbolResolution
        public
        let optional:Bool

        @inlinable public
        init(_ source:ScalarSymbolResolution,
            of target:ScalarSymbolResolution,
            optional:Bool = false)
        {
            self.source = source
            self.target = target
            self.optional = optional
        }
    }
}
extension SymbolRelationship.Requirement:CustomStringConvertible
{
    public
    var description:String
    {
        """
        (\(self.optional ? "optional " : "")requirement: \(self.source), of: \(self.target))
        """
    }
}
