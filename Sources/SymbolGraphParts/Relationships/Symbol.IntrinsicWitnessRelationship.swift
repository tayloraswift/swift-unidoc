import Symbols

extension Symbol
{
    @frozen public
    struct IntrinsicWitnessRelationship:SymbolRelationship, Equatable, Hashable, Sendable
    {
        public
        let source:Symbol.Decl
        public
        let target:Symbol.Decl
        public
        let origin:Symbol.Decl?

        @inlinable public
        init(_ source:Symbol.Decl, of target:Symbol.Decl, origin:Symbol.Decl? = nil)
        {
            self.source = source
            self.target = target
            self.origin = origin
        }
    }
}
extension Symbol.IntrinsicWitnessRelationship:SuperformRelationship
{
    @inlinable public
    var kinks:Phylum.Decl.Kinks { [.intrinsicWitness] }

    public
    func validate(source phylum:Phylum.Decl) -> Bool
    {
        switch phylum
        {
        case .actor:                false
        case .associatedtype:       false
        case .case:                 false
        case .class:                false
        case .deinitializer:        false
        case .enum:                 false
        case .func(nil):            false
        case .func(_?):             true
        case .initializer:          true
        case .macro:                false
        case .operator:             true
        case .protocol:             false
        case .struct:               false
        case .subscript:            true
        case .typealias:            true
        case .var(nil):             false
        case .var(_?):              true
        }
    }
}
extension Symbol.IntrinsicWitnessRelationship:CustomStringConvertible
{
    public
    var description:String
    {
        """
        (default implementation: \(self.source), of: \(self.target))
        """
    }
}
