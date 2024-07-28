import Availability
import JSONDecoding
import LexicalPaths
import Signatures
import Sources
import Symbols

extension SymbolGraphPart
{
    @frozen public
    struct Vertex:Equatable, Sendable
    {
        public
        let usr:Symbol.USR
        public
        let acl:Symbol.ACL
        public
        let phylum:Phylum
        public
        let final:Bool

        public
        let `extension`:ExtensionContext
        public
        let signature:Signature<Symbol.Decl>
        public
        let path:UnqualifiedPath

        public
        var doccomment:Doccomment?
        /// The source location of this symbol, if known. The file string is the absolute path
        /// to the relevant source file.
        public
        var location:SourceLocation<Symbol.File>?

        private
        init(
            usr:Symbol.USR,
            acl:Symbol.ACL,
            phylum:Phylum,
            final:Bool,
            extension:ExtensionContext,
            signature:Signature<Symbol.Decl>,
            path:UnqualifiedPath,
            doccomment:Doccomment?,
            location:SourceLocation<Symbol.File>?)
        {
            self.usr = usr
            self.acl = acl
            self.phylum = phylum
            self.final = final
            self.extension = `extension`
            self.signature = signature
            self.path = path
            self.doccomment = doccomment
            self.location = location
        }
    }
}
extension SymbolGraphPart.Vertex
{
    private
    init(usr:Symbol.USR,
        acl:Symbol.ACL,
        phylum:Phylum,
        availability:Availability,
        doccomment:Doccomment?,
        interfaces:Interfaces?,
        extension:ExtensionContext,
        fragments:__owned [Signature<Symbol.Decl>.Fragment],
        generics:Signature<Symbol.Decl>.Generics,
        location:SourceLocation<Symbol.File>?,
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
            //  Actors would also imply `final`, but we don’t want to flatten that here.
            final: keywords.final,
            extension: `extension`,
            signature: signature,
            path: simplified,
            doccomment: doccomment.flatMap { $0.text.isEmpty ? nil : $0 },
            location: location)
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
                guard
                let position:SourcePosition = .init(line: line, column: column)
                else
                {
                    //  integer overflow.
                    return nil
                }

                return .init(position: position, file: try .uri(file: try $0[.file].decode()))
            },
            path: try json[.path].decode())
    }
}
