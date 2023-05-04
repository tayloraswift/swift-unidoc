import Symbols

extension SymbolRelationship
{
    @frozen public
    struct Extension:Equatable, Hashable, Sendable
    {
        public
        let source:BlockSymbol
        public
        let target:ScalarSymbol

        @inlinable public
        init(_ source:BlockSymbol, of target:ScalarSymbol)
        {
            self.source = source
            self.target = target
        }
    }
}
extension SymbolRelationship.Extension:CustomStringConvertible
{
    public
    var description:String
    {
        """
        (extension: \(self.source), of: \(self.target))
        """
    }
}
