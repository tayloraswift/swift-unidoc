import Availability
import JSONDecoding
import LexicalPaths
import LinkResolution
import MarkdownPluginSwift
import Signatures
import Sources
import Symbols
import UCF

extension SymbolGraphPart {
    @frozen public struct Vertex: Equatable, Sendable {
        public let usr: Symbol.USR
        public let acl: Symbol.ACL
        public let phylum: Phylum
        public let async: Bool
        public let final: Bool

        public let `extension`: ExtensionContext
        public let signature: Signature<Symbol.Decl>
        public let autograph: UCF.Autograph?
        public let path: UnqualifiedPath

        public var doccomment: Doccomment?
        /// The source location of this symbol, if known. The file string is the absolute path
        /// to the relevant source file.
        public var location: SourceLocation<Symbol.File>?

        private init(
            usr: Symbol.USR,
            acl: Symbol.ACL,
            phylum: Phylum,
            async: Bool,
            final: Bool,
            extension: ExtensionContext,
            signature: Signature<Symbol.Decl>,
            autograph: UCF.Autograph?,
            path: UnqualifiedPath,
            doccomment: Doccomment?,
            location: SourceLocation<Symbol.File>?
        ) {
            self.usr = usr
            self.acl = acl
            self.phylum = phylum
            self.async = async
            self.final = final
            self.extension = `extension`
            self.signature = signature
            self.autograph = autograph
            self.path = path
            self.doccomment = doccomment
            self.location = location
        }
    }
}
extension SymbolGraphPart.Vertex {
    private init(
        usr: Symbol.USR,
        acl: Symbol.ACL,
        phylum: Phylum,
        availability: Availability,
        doccomment: Doccomment?,
        interfaces: Interfaces?,
        extension: ExtensionContext,
        fragments: [Signature<Symbol.Decl>.Fragment],
        generics: Signature<Symbol.Decl>.Generics,
        location: SourceLocation<Symbol.File>?,
        path: UnqualifiedPath
    ) {
        /// We will amend the actual phylum later in this function, but none of the amendments
        /// should affect the overloadability of the symbol.
        let isOverloadable: Bool
        if  case .decl(let decl) = phylum {
            isOverloadable = decl.isOverloadable
        } else {
            isOverloadable = false
        }
        /// Static `Self` can appear in more places than just where `isDirectlyOverloadable`,
        /// but it will only be used if that is also true, so there is no point in computing it
        /// for symbols like instance properties.
        var landmarks: SignatureLandmarks = .init()
        var phylum: Phylum = phylum

        let abridged: Signature<Symbol.Decl>.Abridged
        let expanded: Signature<Symbol.Decl>.Expanded

        if  case .block = phylum {
            abridged = .init()
            expanded = .init()
        } else {
            abridged = .init(fragments)
            expanded = .init(
                fragments,
                sugarDictionary: .sSD,
                sugarArray: .sSa,
                sugarOptional: .sSq,
                desugarSelf: isOverloadable
                    ? path.prefixFormatted(inserting: generics.parameters)
                    : nil,
                landmarks: &landmarks
            )
        }

        //  Heuristic for inferring actor types
        if  landmarks.keywords.actor {
            phylum = .decl(.actor)
        }
        //  Heuristic for inferring class members
        if  landmarks.keywords.class {
            switch phylum {
            case .decl(.func(.static)):         phylum = .decl(.func(.class))
            case .decl(.subscript(.static)):    phylum = .decl(.subscript(.class))
            case .decl(.var(.static)):          phylum = .decl(.var(.class))
            default:                            break
            }
        }
        if  case .decl(.macro(_)) = phylum {
            if      landmarks.keywords.attached {
                phylum = .decl(.macro(.attached))
            } else if landmarks.keywords.freestanding {
                phylum = .decl(.macro(.freestanding))
            }
        }

        let signature: Signature<Symbol.Decl> = .init(
            availability: availability,
            abridged: abridged,
            expanded: expanded,
            generics: generics,
            spis: interfaces.map { _ in [] }
        )

        //  strip empty parentheses from last path component
        let simplified: UnqualifiedPath
        if  let index: String.Index = path.last.index(
                path.last.endIndex,
                offsetBy: -2,
                limitedBy: path.last.startIndex
            ),
            path.last[index...] == "()" {
            simplified = .init(path.prefix, .init(path.last[..<index]))
        } else {
            simplified = path
        }

        self.init(
            usr: usr,
            acl: acl,
            phylum: phylum,
            async: landmarks.keywords.async,
            //  Actors would also imply `final`, but we don’t want to flatten that here.
            final: landmarks.keywords.final,
            extension: `extension`,
            signature: signature,
            autograph: isOverloadable
                ? .init(inputs: landmarks.inputs, output: landmarks.output)
                : nil,
            path: simplified,
            doccomment: doccomment.flatMap { $0.text.isEmpty ? nil : $0 },
            location: location
        )
    }
}
extension SymbolGraphPart.Vertex: JSONObjectDecodable {
    public enum CodingKey: String, Sendable {
        case accessLevel
        case availability

        case declarationFragments
        case docComment

        case swiftExtension
        case swiftGenerics
        enum SwiftGenerics: String, Sendable {
            case constraints
            case parameters
        }

        case names
        enum Names: String, Sendable {
            case subHeading
        }

        case identifier
        enum Identifier: String, Sendable {
            case precise
        }

        case spi
        case pathComponents
        case kind
        enum Kind: String, Sendable {
            case identifier
        }

        case location
        enum Location: String, Sendable {
            case uri
            case position
            enum Position: String, Sendable {
                case line
                case character
            }
        }
    }

    public init(json: JSON.ObjectDecoder<CodingKey>) throws {
        self.init(
            usr: try json[.identifier].decode(using: CodingKey.Identifier.self) {
                try $0[.precise].decode()
            },
            acl: try json[.accessLevel].decode(),
            phylum: try json[.kind].decode(using: CodingKey.Kind.self) {
                try $0[.identifier].decode()
            },
            availability: try json[.availability]?.decode() ?? .init(),
            doccomment: try json[.docComment]?.decode(),
            interfaces: try json[.spi]?.decode(as: Bool.self) { $0 ? .init() : nil },
            extension: try json[.swiftExtension]?.decode() ?? .init(),
            fragments: try json[.declarationFragments].decode(),
            generics: try json[.swiftGenerics]?.decode(using: CodingKey.SwiftGenerics.self) {
                var parameters: [GenericParameterWithPosition]? = try $0[.parameters]?.decode()

                /// The parameters should naturally occur in order, but we sort them anyway.
                parameters?.sort { $0.position < $1.position }

                return .init(
                    constraints: try $0[.constraints]?.decode() ?? [],
                    parameters: parameters?.map(\.parameter) ?? []
                )
            } ?? .init(),
            location: try json[.location]?.decode(using: CodingKey.Location.self) {
                let (line, column): (Int, Int) = try $0[.position].decode(
                    using: CodingKey.Location.Position.self
                ) {
                    (try $0[.line].decode(), try $0[.character].decode())
                }
                guard
                let position: SourcePosition = .init(line: line, column: column) else {
                    //  integer overflow.
                    return nil
                }

                return .init(position: position, file: try .uri(file: try $0[.uri].decode()))
            },
            path: try json[.pathComponents].decode()
        )
    }
}
