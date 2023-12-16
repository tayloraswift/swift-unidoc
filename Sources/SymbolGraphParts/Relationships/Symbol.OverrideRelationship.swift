import Symbols

extension Symbol
{
    @frozen public
    struct OverrideRelationship:SymbolRelationship, Equatable, Hashable, Sendable
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
extension Symbol.OverrideRelationship:SuperformRelationship
{
    @inlinable public
    var kinks:Phylum.Decl.Kinks { [.override] }

    public
    func validate(source phylum:Phylum.Decl) -> Bool
    {
        switch phylum
        {
        case .actor:                false
        case .associatedtype:       true
        case .case:                 false
        case .class:                false
        case .deinitializer:        false
        case .enum:                 false
        case .func(nil):            false
        case .func(_?):             true
        //  Protocol init can override another requirement.
        case .initializer:          true
        case .macro:                false
        case .operator:             true
        case .protocol:             false
        case .struct:               false
        case .subscript:            true
        case .typealias:            false
        case .var(nil):             false
        case .var(_?):              true
        }
    }
}
extension Symbol.OverrideRelationship:CustomStringConvertible
{
    public
    var description:String
    {
        """
        (override: \(self.source), of: \(self.target))
        """
    }
}
