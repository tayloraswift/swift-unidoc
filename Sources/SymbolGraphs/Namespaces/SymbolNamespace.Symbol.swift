import JSONDecoding

extension SymbolNamespace
{
    struct Symbol:Equatable
    {
        let visibility:SymbolVisibility
        let fragments:[DeclarationFragment]
        let signature:[DeclarationFragment]
        let phylum:SymbolPhylum
        let path:SymbolPath
        let usr:SymbolIdentifier.CompoundUSR

        private
        init(visibility:SymbolVisibility,
            fragments:[DeclarationFragment],
            signature:[DeclarationFragment],
            phylum:SymbolPhylum,
            path:SymbolPath,
            usr:SymbolIdentifier.CompoundUSR)
        {
            self.visibility = visibility
            self.fragments = fragments
            self.signature = signature
            self.phylum = phylum
            self.path = path
            self.usr = usr
        }
    }
}
extension SymbolNamespace.Symbol
{
    private
    init(visibility:SymbolVisibility,
        fragments:[DeclarationFragment],
        signature:[DeclarationFragment],
        kind:Kind,
        path:SymbolPath,
        usr:SymbolIdentifier.CompoundUSR)
    {
        self.visibility = visibility
        self.fragments = fragments
        self.signature = signature

        switch kind
        {
        case .protocol:             self.phylum = .protocol
        case .associatedtype:       self.phylum = .associatedtype
        case .enum:                 self.phylum = .enum
        case .struct:               self.phylum = .struct
        case .class:                self.phylum = .class
        case .case:                 self.phylum = .case
        case .initializer:          self.phylum = .initializer
        case .deinitializer:        self.phylum = .deinitializer
        case .instanceMethod:       self.phylum = .instanceMethod
        case .instanceProperty:     self.phylum = .instanceProperty
        case .instanceSubscript:    self.phylum = .instanceSubscript
        case .typeMethod:           self.phylum = .typeMethod
        case .typeProperty:         self.phylum = .typeProperty
        case .typeSubscript:        self.phylum = .typeSubscript

        case .operator:             self.phylum = path.prefix.isEmpty ?
            .operator : .typeOperator
        
        case .func:                 self.phylum = .func
        case .var:                  self.phylum = .var
        case .typealias:            self.phylum = .typealias
        }

        self.path = path
        self.usr = usr
    }
}
extension SymbolNamespace.Symbol:JSONObjectDecodable
{
    enum CodingKeys:String
    {
        case fragments = "declarationFragments"

        case names
        enum Names:String
        {
            case subheading = "subHeading"
        }

        case identifier
        enum Identifier:String
        {
            case precise
        }

        case path = "pathComponents"
        case kind
        enum Kind:String
        {
            case identifier
        }

        case visibility = "accessLevel"
    }

    init(json:JSON.ObjectDecoder<CodingKeys>) throws
    {
        self.init(visibility: try json[.visibility].decode(),
            fragments: try json[.fragments].decode(),
            signature: try json[.names].decode(using: CodingKeys.Names.self)
            {
                try $0[.subheading].decode()
            },
            kind: try json[.kind].decode(using: CodingKeys.Kind.self)
            {
                try $0[.identifier].decode()
            },
            path: try json[.path].decode(),
            usr: try json[.identifier].decode(using: CodingKeys.Identifier.self)
            {
                try $0[.precise].decode()
            })
    }
}
