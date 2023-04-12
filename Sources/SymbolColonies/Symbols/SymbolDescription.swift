import JSONDecoding

@frozen public
struct SymbolDescription:Equatable, Sendable
{
    public
    let documentation:Documentation?
    public
    let availability:SymbolAvailability
    public
    let interfaces:SymbolInterfaces?
    public
    let visibility:SymbolVisibility
    public
    let fragments:Declaration<ScalarSymbolResolution>

    public
    let `extension`:ExtensionContext
    public
    let generics:GenericSignature<ScalarSymbolResolution>

    public
    let location:SourceLocation<String>?
    public
    let phylum:SymbolPhylum
    public
    let path:LexicalPath
    public
    let usr:UnifiedSymbolResolution

    private
    init(documentation:Documentation?,
        availability:SymbolAvailability,
        interfaces:SymbolInterfaces?,
        visibility:SymbolVisibility,
        fragments:Declaration<ScalarSymbolResolution>,
        extension:ExtensionContext,
        generics:GenericSignature<ScalarSymbolResolution>,
        location:SourceLocation<String>?,
        phylum:SymbolPhylum,
        path:LexicalPath,
        usr:UnifiedSymbolResolution)
    {
        self.documentation = documentation
        self.availability = availability
        self.interfaces = interfaces
        self.visibility = visibility
        self.fragments = fragments

        self.extension = `extension`
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
    init(documentation:Documentation?,
        availability:SymbolAvailability,
        interfaces:SymbolInterfaces?,
        visibility:SymbolVisibility,
        expanded:
        __shared [DeclarationFragment<ScalarSymbolResolution, DeclarationFragmentClass?>],
        abridged:
        __shared [DeclarationFragment<ScalarSymbolResolution, DeclarationFragmentClass?>],
        extension:ExtensionContext,
        generics:GenericSignature<ScalarSymbolResolution>,
        location:SourceLocation<String>?,
        type:SymbolDescriptionType,
        path:LexicalPath,
        usr:UnifiedSymbolResolution)
    {
        var phylum:SymbolPhylum
        switch type
        {
        case .associatedtype:       phylum = .associatedtype
        case .enum:                 phylum = .enum
        case .extension:            phylum = .extension
        case .case:                 phylum = .case
        case .class:                phylum = .class
        case .deinitializer:        phylum = .deinitializer
        case .globalFunction:       phylum = .func(nil)
        case .globalVariable:       phylum = .var(nil)
        case .initializer:          phylum = .initializer
        case .instanceFunction:     phylum = .func(.instance)
        case .instanceSubscript:    phylum = .subscript(.instance)
        case .instanceVariable:     phylum = .var(.instance)
        case .protocol:             phylum = .protocol
        case .macro:                phylum = .macro
        case .operator:             phylum = .operator
        case .struct:               phylum = .struct
        case .typealias:            phylum = .typealias
        case .typeFunction:         phylum = .func(.static)
        case .typeSubscript:        phylum = .subscript(.static)
        case .typeVariable:         phylum = .var(.static)
        }
        
        fragments:
        for fragment:DeclarationFragment<ScalarSymbolResolution, DeclarationFragmentClass?>
            in expanded where fragment.color == .keyword
        {
            switch fragment.spelling
            {
            //  Heuristic for inferring actor types
            case "actor":
                phylum = .actor
        
            //  Heuristic for inferring class members
            case "class":
                switch phylum
                {
                case .func(.static):        phylum = .func(.class)
                case .subscript(.static):   phylum = .subscript(.class)
                case .var(.static):         phylum = .var(.class)
                default:                    break
                }
            
            default:
                continue
            }

            break
        }
        
        let fragments:Declaration<ScalarSymbolResolution>
        if  case .actor = phylum
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
        }
        else
        {
            fragments = .init(expanded: expanded, abridged: abridged)
        }

        //  strip empty parentheses from last path component
        let simplified:LexicalPath
        if  let index:String.Index = path.last.index(path.last.endIndex,
                offsetBy: -2,
                limitedBy: path.last.startIndex),
            path.last[index...] == "()"
        {
            simplified = .init(path.prefix, .init(path.last[..<index]))
        }
        else
        {
            simplified = path
        }

        self.init(
            documentation: documentation.flatMap { $0.text.isEmpty ? nil : $0 },
            availability: availability,
            interfaces: interfaces,
            visibility: visibility,
            fragments: fragments,
            extension: `extension`,
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
        case documentation = "docComment"

        case `extension` = "swiftExtension"
        case generics = "swiftGenerics"

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

        case interfaces = "spi"
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

        case visibility = "accessLevel"
    }

    public
    init(json:JSON.ObjectDecoder<CodingKeys>) throws
    {
        self.init(
            documentation: try json[.documentation]?.decode(),
            availability: try json[.availability]?.decode() ?? [:],
            interfaces: try json[.interfaces]?.decode(as: Bool.self) { $0 ? .init() : nil },
            visibility: try json[.visibility].decode(),
            expanded: try json[.declaration].decode(),
            abridged: try json[.names].decode(using: CodingKeys.Names.self)
            {
                try $0[.subheading].decode()
            },
            extension: try json[.extension]?.decode() ?? .init(),
            generics: try json[.generics]?.decode() ?? .init(),
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
