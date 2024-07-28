import Symbols

extension Symbol
{
    @frozen public
    struct FeatureRelationship:SymbolRelationship, Equatable, Hashable, Sendable
    {
        /// Note that `source.heir` may not be the same as ``target``, as ``target`` may
        /// encode an extension block instead of a type.
        public
        let source:Symbol.Decl.Vector
        public
        let target:Symbol.USR
        public
        let origin:Symbol.Decl?

        @inlinable public
        init(_ source:Symbol.Decl.Vector, in target:Symbol.USR, origin:Symbol.Decl? = nil)
        {
            self.source = source
            self.target = target
            self.origin = origin
        }
    }
}
extension Symbol.FeatureRelationship:CustomStringConvertible
{
    public
    var description:String
    {
        """
        (feature: \(self.source), of: \(self.target))
        """
    }
}
