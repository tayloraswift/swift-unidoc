import Availability
import Declarations
import Fragments
import Generics
import JSONDecoding
import LexicalPaths
import SourceMaps
import Symbols

@frozen public
struct SymbolDescription:Equatable, Sendable
{
    public
    let usr:Symbol
    public
    let phylum:SymbolPhylum

    public
    let declaration:Declaration<Symbol.Scalar>
    public
    let doccomment:Doccomment?
    public
    let interfaces:Interfaces?
    public
    let visibility:Visibility
    public
    let `extension`:ExtensionContext

    /// The source location of this symbol, if known. The file string is the
    /// absolute path to the relevant source file, and starts with `file://`.
    public
    let location:SourceLocation<String>?
    public
    let path:LexicalPath

    private
    init(_ usr:Symbol,
        phylum:SymbolPhylum,
        declaration:Declaration<Symbol.Scalar>,
        doccomment:Doccomment?,
        interfaces:Interfaces?,
        visibility:Visibility,
        extension:ExtensionContext,
        location:SourceLocation<String>?,
        path:LexicalPath)
    {
        self.declaration = declaration
        self.doccomment = doccomment
        self.interfaces = interfaces
        self.visibility = visibility

        self.extension = `extension`

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
        phylum:SymbolPhylum,
        availability:Availability,
        doccomment:Doccomment?,
        interfaces:Interfaces?,
        visibility:Visibility,
        expanded:
        __shared [DeclarationFragment<Symbol.Scalar, DeclarationFragmentClass?>],
        abridged:
        __shared [DeclarationFragment<Symbol.Scalar, DeclarationFragmentClass?>],
        extension:ExtensionContext,
        generics:GenericSignature<Symbol.Scalar>,
        location:SourceLocation<String>?,
        path:LexicalPath)
    {
        var phylum:SymbolPhylum = phylum

        fragments:
        for fragment:DeclarationFragment<Symbol.Scalar, DeclarationFragmentClass?>
            in expanded where fragment.color == .keyword
        {
            switch fragment.spelling
            {
            //  Heuristic for inferring actor types
            case "actor":
                phylum = .scalar(.actor)
        
            //  Heuristic for inferring class members
            case "class":
                switch phylum
                {
                case .scalar(.func(.static)):       phylum = .scalar(.func(.class))
                case .scalar(.subscript(.static)):  phylum = .scalar(.subscript(.class))
                case .scalar(.var(.static)):        phylum = .scalar(.var(.class))
                default:                            break
                }
            
            default:
                continue
            }

            break
        }
        
        let fragments:DeclarationFragments<Symbol.Scalar>
        if  case .scalar(.actor) = phylum
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

        self.init(usr,
            phylum: phylum,
            declaration: .init(availability: availability,
                fragments: fragments,
                generics: generics),
            doccomment: doccomment.flatMap { $0.text.isEmpty ? nil : $0 },
            interfaces: interfaces,
            visibility: visibility,
            extension: `extension`,
            location: location,
            path: simplified)
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
    init(json:JSON.ObjectDecoder<CodingKeys>) throws
    {
        self.init(try json[.identifier].decode(using: CodingKeys.Identifier.self)
            {
                try $0[.precise].decode()
            },
            phylum: try json[.kind].decode(using: CodingKeys.Kind.self)
            {
                try $0[.identifier].decode()
            },
            availability: try json[.availability]?.decode() ?? [:],
            doccomment: try json[.doccomment]?.decode(),
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
                let (line, column):(Int, Int) = try $0[.position].decode(
                    using: CodingKeys.Location.Position.self)
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
