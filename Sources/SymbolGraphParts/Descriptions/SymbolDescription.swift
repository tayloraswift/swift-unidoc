import Availability
import JSONDecoding
import LexicalPaths
import Signatures
import Sources
import Symbols
import Unidoc

@frozen public
struct SymbolDescription:Equatable, Sendable
{
    public
    let usr:Symbol
    public
    let phylum:Unidoc.Phylum

    public
    let doccomment:Doccomment?
    public
    let interfaces:Interfaces?
    public
    let visibility:Visibility
    public
    let `extension`:ExtensionContext
    public
    let signature:Signature<Symbol.Decl>

    /// The source location of this symbol, if known. The file string is the
    /// absolute path to the relevant source file, and starts with `file://`.
    public
    let location:SourceLocation<String>?
    public
    let path:UnqualifiedPath

    private
    init(_ usr:Symbol,
        phylum:Unidoc.Phylum,
        doccomment:Doccomment?,
        interfaces:Interfaces?,
        visibility:Visibility,
        extension:ExtensionContext,
        signature:Signature<Symbol.Decl>,
        location:SourceLocation<String>?,
        path:UnqualifiedPath)
    {
        self.doccomment = doccomment
        self.interfaces = interfaces
        self.visibility = visibility
        self.extension = `extension`
        self.signature = signature

        self.location = location
        self.phylum = phylum
        self.path = path
        self.usr = usr
    }
}
extension SymbolDescription
{
    private
    init(_ usr:Symbol,
        phylum:Unidoc.Phylum,
        availability:Availability,
        doccomment:Doccomment?,
        interfaces:Interfaces?,
        visibility:Visibility,
        extension:ExtensionContext,
        expanded:__shared [Signature<Symbol.Decl>.Fragment],
        abridged:__shared [Signature<Symbol.Decl>.Fragment],
        generics:Signature<Symbol.Decl>.Generics,
        location:SourceLocation<String>?,
        path:UnqualifiedPath)
    {
        var phylum:Unidoc.Phylum = phylum

        for fragment:Signature<Symbol.Decl>.Fragment
            in expanded where fragment.color == .keyword
        {
            switch fragment.spelling
            {
            //  Heuristic for inferring actor types
            case "actor":
                phylum = .decl(.actor)

            //  Heuristic for inferring class members
            case "class":
                switch phylum
                {
                case .decl(.func(.static)):       phylum = .decl(.func(.class))
                case .decl(.subscript(.static)):  phylum = .decl(.subscript(.class))
                case .decl(.var(.static)):        phylum = .decl(.var(.class))
                default:                            break
                }

            default:
                continue
            }

            break
        }

        let signature:Signature<Symbol.Decl>
        if  case .decl(.actor) = phylum
        {
            //  SymbolGraphGen incorrectly prints the fragment as 'class' in
            //  the abridged signature
            signature = .init(availability: availability,
                abridged: .init(abridged.lazy.map
                {
                    if  case .keyword = $0.color,
                        case "class" = $0.spelling
                    {
                        return $0.spelled("actor")
                    }
                    else
                    {
                        return $0
                    }
                }),
                expanded: .init(expanded),
                generics: generics)
        }
        else
        {
            signature = .init(availability: availability,
                abridged: .init(abridged),
                expanded: .init(expanded),
                generics: generics)
        }

        //  strip empty parentheses from last path component
        let simplified:UnqualifiedPath
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

        self.init(usr,
            phylum: phylum,
            doccomment: doccomment.flatMap { $0.text.isEmpty ? nil : $0 },
            interfaces: interfaces,
            visibility: visibility,
            extension: `extension`,
            signature: signature,
            location: location,
            path: simplified)
    }
}
extension SymbolDescription:JSONObjectDecodable
{
    public
    enum CodingKey:String
    {
        case availability

        case declaration = "declarationFragments"
        case doccomment = "docComment"

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
            case file = "uri"
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
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        self.init(try json[.identifier].decode(using: CodingKey.Identifier.self)
            {
                try $0[.precise].decode()
            },
            phylum: try json[.kind].decode(using: CodingKey.Kind.self)
            {
                try $0[.identifier].decode()
            },
            availability: try json[.availability]?.decode() ?? .init(),
            doccomment: try json[.doccomment]?.decode(),
            interfaces: try json[.interfaces]?.decode(as: Bool.self) { $0 ? .init() : nil },
            visibility: try json[.visibility].decode(),
            extension: try json[.extension]?.decode() ?? .init(),
            expanded: try json[.declaration].decode(),
            abridged: try json[.names].decode(using: CodingKey.Names.self)
            {
                try $0[.subheading].decode()
            },
            generics: try json[.generics]?.decode() ?? .init(),
            location: try json[.location]?.decode(using: CodingKey.Location.self)
            {
                let (line, column):(Int, Int) = try $0[.position].decode(
                    using: CodingKey.Location.Position.self)
                {
                    (try $0[.line].decode(), try $0[.column].decode())
                }
                if  let position:SourcePosition = .init(line: line, column: column)
                {
                    return .init(position: position, file: try $0[.file].decode())
                }
                else
                {
                    //  integer overflow.
                    return nil
                }
            },
            path: try json[.path].decode())
    }
}
