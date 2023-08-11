import Symbols

extension Symbol
{
    @frozen public
    struct ExtensionRelationship:Equatable, Hashable, Sendable
    {
        public
        let source:Symbol.Block
        public
        let target:Symbol.Decl

        @inlinable public
        init(_ source:Symbol.Block, of target:Symbol.Decl)
        {
            self.source = source
            self.target = target
        }
    }
}
extension Symbol.ExtensionRelationship:SymbolRelationship
{
    @inlinable public
    var origin:Symbol.Decl? { nil }
}
extension Symbol.ExtensionRelationship:CustomStringConvertible
{
    public
    var description:String
    {
        """
        (extension: \(self.source), of: \(self.target))
        """
    }
}
