import Symbols

extension Symbol
{
    @frozen public
    struct InheritanceRelationship:SymbolRelationship, Equatable, Hashable, Sendable
    {
        public
        let source:Symbol.Decl
        public
        let target:Symbol.Decl
        public
        let origin:Symbol.Decl?

        @inlinable public
        init(by source:Symbol.Decl, of target:Symbol.Decl, origin:Symbol.Decl? = nil)
        {
            self.source = source
            self.target = target
            self.origin = origin
        }
    }
}
extension Symbol.InheritanceRelationship:SuperformRelationship
{
    @inlinable public
    var kinks:Phylum.Decl.Kinks { [] }

    public
    func validate(source phylum:Phylum.Decl) -> Bool
    {
        switch phylum
        {
        case .actor:                false
        case .associatedtype:       false
        case .case:                 false
        case .class:                true
        case .deinitializer:        false
        case .enum:                 false
        case .func:                 false
        case .initializer:          false
        case .macro:                false
        case .operator:             false
        case .protocol:             true
        case .struct:               false
        case .subscript:            false
        case .typealias:            false
        case .var:                  false
        }
    }
}
extension Symbol.InheritanceRelationship:CustomStringConvertible
{
    public
    var description:String
    {
        """
        /\(self.source) INHERITS FROM \(self.target) (\(self.origin == nil ? 0 : 1) origin(s))/
        """
    }
}
