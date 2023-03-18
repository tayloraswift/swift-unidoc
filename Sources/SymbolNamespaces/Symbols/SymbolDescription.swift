import JSONDecoding

@frozen public
struct SymbolDescription:Equatable, Sendable
{
    public
    let doccomment:Doccomment?
    public
    let spi:SymbolSPI?

    public
    let availability:SymbolAvailability
    public
    let visibility:SymbolVisibility
    public
    let fragments:Declaration<SymbolIdentifier>
    public
    let generics:GenericContext
    
    public
    let location:SourceLocation<String>?
    public
    let phylum:SymbolPhylum
    public
    let path:SymbolPath
    public
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
        expanded:__shared [DeclarationFragment<SymbolIdentifier, DeclarationFragmentClass?>],
        abridged:__shared [DeclarationFragment<SymbolIdentifier, DeclarationFragmentClass?>],
        generics:GenericContext,
        location:SourceLocation<String>?,
        type:SymbolDescriptionType,
        path:SymbolPath,
        usr:UnifiedSymbolResolution)
    {
        let fragments:Declaration<SymbolIdentifier>
        let phylum:SymbolPhylum
        //  Heuristic for inferring actor types
        if  case "actor"? = expanded.first(where: { $0.color == .keyword })?.spelling
        {
            //  SymbolGraphGen incorrectly prints the fragment as 'class' in
            //  the abridged signature
            fragments = .init(expanded: expanded, abridged: abridged.map
            {
                if  case .keyword? = $0.color,
                    case "class" = $0.spelling
                {
                    return $0.spelled("actor")
                }
                else
                {
                    return $0
                }
            })

            phylum = .actor
        }
        else
        {
            fragments = .init(expanded: expanded, abridged: abridged)

            switch type
            {
            case .associatedtype:       phylum = .associatedtype
            case .enum:                 phylum = .enum
            case .extension:            phylum = .extension
            case .case:                 phylum = .case
            case .class:                phylum = .class
            case .deinitializer:        phylum = .deinitializer
            case .func:                 phylum = .func
            case .initializer:          phylum = .initializer
            case .instanceMethod:       phylum = .instanceMethod
            case .instanceProperty:     phylum = .instanceProperty
            case .instanceSubscript:    phylum = .instanceSubscript
            case .protocol:             phylum = .protocol
            case .macro:                phylum = .macro
            case .struct:               phylum = .struct
            case .typealias:            phylum = .typealias
            case .typeMethod:           phylum = .typeMethod
            case .typeProperty:         phylum = .typeProperty
            case .typeSubscript:        phylum = .typeSubscript

            case .operator:             phylum = path.prefix.isEmpty ?
                .operator : .typeOperator
            
            case .var:                  phylum = .var
            }
        }

        //  strip empty parentheses from last path component
        let simplified:SymbolPath
        if  let index:String.Index = path.last.index(path.last.endIndex,
                offsetBy: -2,
                limitedBy: path.last.startIndex),
            path.last[index...] == "()"
        {
            simplified = .init(prefix: path.prefix, last: .init(path.last[..<index]))
        }
        else
        {
            simplified = path
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
            path: simplified,
            usr: usr)
    }
}
extension SymbolDescription:JSONObjectDecodable
{
    public
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

    public
    init(json:JSON.ObjectDecoder<CodingKeys>) throws
    {
        self.init(
            doccomment: try json[.doccomment]?.decode(),
            spi: try json[.spi]?.decode(as: Bool.self) { $0 ? .init() : nil },
            availability: try json[.availability]?.decode() ?? [:],
            visibility: try json[.visibility].decode(),
            expanded: try json[.declaration].decode(),
            abridged: try json[.names].decode(using: CodingKeys.Names.self)
            {
                try $0[.subheading].decode()
            },
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
