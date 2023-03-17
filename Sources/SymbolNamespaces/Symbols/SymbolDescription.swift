import JSONDecoding

struct SymbolDescription:Equatable, Sendable
{
    let doccomment:Doccomment?
    let spi:SymbolSPI?

    let availability:SymbolAvailability
    let visibility:SymbolVisibility
    let fragments:Declaration<SymbolIdentifier>
    let generics:GenericContext
    
    let location:SourceLocation<String>?
    let phylum:SymbolPhylum
    let path:SymbolPath
    let usr:UnifiedSymbolResolution

    private
    init(doccomment:Doccomment?,
        spi:SymbolSPI?,
        availability:SymbolAvailability,
        visibility:SymbolVisibility,
        fragments:Declaration<SymbolIdentifier>,
        generics:GenericContext,
        location:SourceLocation<String>?,
        phylum:SymbolPhylum,
        path:SymbolPath,
        usr:UnifiedSymbolResolution)
    {
        self.doccomment = doccomment
        self.spi = spi

        self.availability = availability
        self.visibility = visibility
        self.fragments = fragments
        self.generics = generics

        self.location = location
        self.phylum = phylum
        self.path = path
        self.usr = usr
    }
}
extension SymbolDescription
{
    private
    init(doccomment:Doccomment?,
        spi:SymbolSPI?,
        availability:SymbolAvailability,
        visibility:SymbolVisibility,
        fragments:Declaration<SymbolIdentifier>,
        generics:GenericContext,
        location:SourceLocation<String>?,
        type:SymbolDescriptionType,
        path:SymbolPath,
        usr:UnifiedSymbolResolution)
    {
        let phylum:SymbolPhylum
        switch type
        {
        case .protocol:             phylum = .protocol
        case .associatedtype:       phylum = .associatedtype
        case .enum:                 phylum = .enum
        case .struct:               phylum = .struct
        case .class:                phylum = .class
        case .case:                 phylum = .case
        case .initializer:          phylum = .initializer
        case .deinitializer:        phylum = .deinitializer
        case .instanceMethod:       phylum = .instanceMethod
        case .instanceProperty:     phylum = .instanceProperty
        case .instanceSubscript:    phylum = .instanceSubscript
        case .typeMethod:           phylum = .typeMethod
        case .typeProperty:         phylum = .typeProperty
        case .typeSubscript:        phylum = .typeSubscript

        case .operator:             phylum = path.prefix.isEmpty ?
            .operator : .typeOperator
        
        case .func:                 phylum = .func
        case .var:                  phylum = .var
        case .typealias:            phylum = .typealias
    
        case .extension:
            fatalError("unimplemented")
        }

        self.init(
            doccomment: doccomment.flatMap { $0.text.isEmpty ? nil : $0 },
            spi: spi,
            availability: availability,
            visibility: visibility,
            fragments: fragments,
            generics: generics,
            location: location,
            phylum: phylum,
            path: path,
            usr: usr)
    }
}
extension SymbolDescription:JSONObjectDecodable
{
    enum CodingKeys:String
    {
        case availability

        case declaration = "declarationFragments"
        case doccomment = "docComment"

        case `extension` = "swiftExtension"
        enum Extension:String
        {
            case constraints
        }

        case generics = "swiftGenerics"
        enum Generics:String
        {
            case parameters
            case constraints
        }

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

        case location
        enum Location:String
        {
            case uri
            case position
            enum Position:String
            {
                case line
                case column = "character"
            }
        }

        case spi
        case visibility = "accessLevel"
    }

    init(json:JSON.ObjectDecoder<CodingKeys>) throws
    {
        self.init(
            doccomment: try json[.doccomment]?.decode(),
            spi: try json[.spi]?.decode(as: Bool.self) { $0 ? .init() : nil },
            availability: try json[.availability]?.decode() ?? [:],
            visibility: try json[.visibility].decode(),
            fragments: .init(
                expanded: try json[.declaration].decode(),
                abridged: try json[.names].decode(using: CodingKeys.Names.self)
                {
                    try $0[.subheading].decode()
                }),
            generics: .init(
                conditions: try json[.extension]?.decode(using: CodingKeys.Extension.self)
                {
                    try $0[.constraints]?.decode() ?? []
                },
                generics: try json[.generics]?.decode(using: CodingKeys.Generics.self)
                {
                    (
                        try $0[.constraints]?.decode() ?? [],
                        try $0[.parameters]?.decode() ?? []
                    )
                }),
            location: try json[.location]?.decode(using: CodingKeys.Location.self)
            {
                let file:String = try $0[.uri].decode()
                return try $0[.position].decode(using: CodingKeys.Location.Position.self)
                {
                    .init(file: file,
                        try $0[.line].decode(),
                        try $0[.column].decode())
                }
            },
            type: try json[.kind].decode(using: CodingKeys.Kind.self)
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
