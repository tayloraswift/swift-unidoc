import Symbols

extension Symbol
{
    @frozen public
    struct MemberRelationship:SymbolRelationship, Equatable, Hashable, Sendable
    {
        public
        let source:Symbol.Decl
        public
        let target:Symbol.USR
        public
        let origin:Symbol.Decl?

        @inlinable public
        init(_ source:Symbol.Decl, in target:Symbol.USR, origin:Symbol.Decl? = nil)
        {
            self.source = source
            self.target = target
            self.origin = origin
        }
    }
}
extension Symbol.MemberRelationship:NestingRelationship
{
    @inlinable public
    var kinks:Phylum.Decl.Kinks { [] }

    public
    func validate(source phylum:Phylum.Decl) -> Bool
    {
        switch phylum
        {
        case .actor:                true
        case .associatedtype:       true
        case .case:                 true
        case .class:                true
        case .deinitializer:        true
        case .enum:                 true
        case .func(nil):            false
        case .func(_?):             true
        case .initializer:          true
        case .macro:                true // ???
        case .operator:             true
        case .protocol:             true // SE-404
        case .struct:               true
        case .subscript:            true
        case .typealias:            true
        case .var(nil):             false
        case .var(_?):              true
        }
    }
}
extension Symbol.MemberRelationship:CustomStringConvertible
{
    public
    var description:String
    {
        """
        /\(self.source) MEMBER OF \(self.target) (\(self.origin == nil ? 0 : 1) origin(s))/
        """
    }
}
