import Symbols

extension SymbolRelationship
{
    @frozen public
    struct Extension:Equatable, Hashable, Sendable
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
