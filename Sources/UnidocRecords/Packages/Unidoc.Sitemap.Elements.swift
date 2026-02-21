import BSON
import UnidocAPI

extension Unidoc.Sitemap {
    @frozen public struct Elements: Equatable, Sendable {
        @usableFromInline internal var bytes: ArraySlice<UInt8>

        @inlinable internal init(bytes: ArraySlice<UInt8>) {
            self.bytes = bytes
        }
    }
}
extension Unidoc.Sitemap.Elements {
    @inlinable static var separator: UInt8 { 0x0A }
}
extension Unidoc.Sitemap.Elements: Sequence {
    @inlinable public func makeIterator() -> Iterator {
        .init(bytes: self.bytes)
    }
}
extension Unidoc.Sitemap.Elements: BSONBinaryEncodable {
    @inlinable public func encode(to bson: inout BSON.BinaryEncoder) {
        bson += self.bytes
    }
}
extension Unidoc.Sitemap.Elements: BSONBinaryDecodable {
    @inlinable public init(bson: BSON.BinaryDecoder) {
        self.init(bytes: bson.bytes)
    }
}
extension Unidoc.Sitemap.Elements {
    public init(
        cultures: __shared [Unidoc.CultureVertex],
        articles: __shared [Unidoc.ArticleVertex],
        decls: __shared [Unidoc.DeclVertex]
    ) {
        /// At the moment, we can’t fully rely on the `language` property of the decl flags,
        /// due to backwards compatibility with the old symbol graph format.
        let ignoredModules: Set<Unidoc.Scalar> = cultures.reduce(into: []) {
            switch $1.module.language {
            case nil, .swift?:  return
            case _?:            $0.insert($1.id)
            }
        }

        let lines: BSON.BinaryView<ArraySlice<UInt8>> = .init {
            for vertex: Unidoc.CultureVertex in cultures {
                $0 += vertex.shoot
                $0.append(Unidoc.Sitemap.Elements.separator)
            }
            for vertex: Unidoc.ArticleVertex in articles {
                $0 += vertex.shoot
                $0.append(Unidoc.Sitemap.Elements.separator)
            }
            for vertex: Unidoc.DeclVertex in decls {
                //  Skip C and C++ declarations.
                guard !ignoredModules.contains(vertex.culture),
                case .swift = vertex.flags.language,
                case .s = vertex.symbol.language else {
                    continue
                }

                $0 += vertex.shoot
                $0.append(Unidoc.Sitemap.Elements.separator)
            }
        }

        self.init(bytes: lines.bytes)
    }
}
