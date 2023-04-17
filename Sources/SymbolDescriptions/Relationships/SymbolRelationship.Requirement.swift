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
        let origin:ScalarSymbolResolution?
        public
        let optional:Bool

        init(_ source:ScalarSymbolResolution,
            of target:ScalarSymbolResolution,
            origin:ScalarSymbolResolution? = nil,
            optional:Bool = false)
        {
            self.source = source
            self.target = target
            self.origin = origin
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
