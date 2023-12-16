import Symbols

extension Symbol
{
    @frozen public
    struct MemberRelationship:SymbolRelationship, Equatable, Hashable, Sendable
    {
        public
        let source:Symbol.USR
        public
        let target:Symbol.USR
        public
        let origin:Symbol.Decl?

        @inlinable public
        init(_ source:Symbol.USR, in target:Symbol.USR, origin:Symbol.Decl? = nil)
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

    @inlinable public
    var scope:Symbol.USR { self.target }

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
        (member: \(self.source), of: \(self.target))
        """
    }
}
