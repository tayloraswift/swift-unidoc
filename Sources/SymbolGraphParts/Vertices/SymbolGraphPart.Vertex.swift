import Availability
import JSONDecoding
import LexicalPaths
import Signatures
import Sources
import Symbols

@available(*, deprecated, renamed: "SymbolGraphPart.Vertex")
public
typealias SymbolDescription = SymbolGraphPart.Vertex

extension SymbolGraphPart
{
    @frozen public
    struct Vertex:Equatable, Sendable
    {
        public
        let usr:Symbol.USR
        public
        let acl:ACL
        public
        let phylum:Phylum

        public
        let doccomment:Doccomment?
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
        init(
            usr:Symbol.USR,
            acl:ACL,
            phylum:Phylum,
            doccomment:Doccomment?,
            extension:ExtensionContext,
            signature:Signature<Symbol.Decl>,
            location:SourceLocation<String>?,
            path:UnqualifiedPath)
        {
            self.usr = usr
            self.acl = acl
            self.phylum = phylum
            self.doccomment = doccomment
            self.extension = `extension`
            self.signature = signature
            self.location = location
            self.path = path
        }
    }
}
extension SymbolGraphPart.Vertex
{
    private
    init(usr:Symbol.USR,
        acl:ACL,
        phylum:Phylum,
        availability:Availability,
        doccomment:Doccomment?,
        interfaces:Interfaces?,
        extension:ExtensionContext,
        fragments:__owned [Signature<Symbol.Decl>.Fragment],
        generics:Signature<Symbol.Decl>.Generics,
        location:SourceLocation<String>?,
        path:UnqualifiedPath)
    {
        var keywords:Signature<Symbol.Decl>.Expanded.InterestingKeywords = .init()
        var phylum:Phylum = phylum

        let abridged:Signature<Symbol.Decl>.Abridged
        let expanded:Signature<Symbol.Decl>.Expanded

        if  case .block = phylum
        {
            abridged = .init()
            expanded = .init()
        }
        else
        {
            abridged = .init(fragments)
            expanded = .init(fragments, keywords: &keywords)
        }

        //  Heuristic for inferring actor types
        if  keywords.actor
        {
            phylum = .decl(.actor)
        }
        //  Heuristic for inferring class members
        if  keywords.class
        {
            switch phylum
            {
            case .decl(.func(.static)):         phylum = .decl(.func(.class))
            case .decl(.subscript(.static)):    phylum = .decl(.subscript(.class))
            case .decl(.var(.static)):          phylum = .decl(.var(.class))
            default:                            break
            }
        }
        if  case .decl(.macro(_)) = phylum
        {
            if      keywords.attached
            {
                phylum = .decl(.macro(.attached))
            }
            else if keywords.freestanding
            {
                phylum = .decl(.macro(.freestanding))
            }
        }

        let signature:Signature<Symbol.Decl> = .init(availability: availability,
            abridged: abridged,
            expanded: expanded,
            generics: generics,
            spis: interfaces.map { _ in [] })

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

        self.init(
            usr: usr,
            acl: acl,
            phylum: phylum,
            doccomment: doccomment.flatMap { $0.text.isEmpty ? nil : $0 },
            extension: `extension`,
            signature: signature,
            location: location,
            path: simplified)
    }
}
extension SymbolGraphPart.Vertex:JSONObjectDecodable
{
    public
    enum CodingKey:String, Sendable
    {
        case acl = "accessLevel"
        case availability

        case declaration = "declarationFragments"
        case doccomment = "docComment"

        case `extension` = "swiftExtension"
        case generics = "swiftGenerics"

        case names
        enum Names:String, Sendable
        {
            case subheading = "subHeading"
        }

        case identifier
        enum Identifier:String, Sendable
        {
            case precise
        }

        case interfaces = "spi"
        case path = "pathComponents"
        case kind
        enum Kind:String, Sendable
        {
            case identifier
        }

        case location
        enum Location:String, Sendable
        {
            case file = "uri"
            case position
            enum Position:String, Sendable
            {
                case line
                case column = "character"
            }
        }
    }

    public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        self.init(
            usr: try json[.identifier].decode(using: CodingKey.Identifier.self)
            {
                try $0[.precise].decode()
            },
            acl: try json[.acl].decode(),
            phylum: try json[.kind].decode(using: CodingKey.Kind.self)
            {
                try $0[.identifier].decode()
            },
            availability: try json[.availability]?.decode() ?? .init(),
            doccomment: try json[.doccomment]?.decode(),
            interfaces: try json[.interfaces]?.decode(as: Bool.self) { $0 ? .init() : nil },
            extension: try json[.extension]?.decode() ?? .init(),
            fragments: try json[.declaration].decode(),
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
