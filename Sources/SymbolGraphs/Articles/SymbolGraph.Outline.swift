
import BSON
import Sources

extension SymbolGraph {
    @frozen public enum Outline: Equatable, Hashable, Sendable {
        case vector(Int32, self: Int32, text: OutlineText)
        case vertex(Int32, text: OutlineText)
        case symbol(Int32)
        /// A URL fragment, without the hashtag (`#`) prefix.
        case fragment(String)
        case location(SourceLocation<Int32>)
        case unresolved(Unresolved)
    }
}
extension SymbolGraph.Outline {
    @available(*, unavailable, message: "Obsoleted in 0.10.0.")
    @inlinable public static func unresolved(
        doc link: String,
        location: SourceLocation<Int32>?
    ) -> Self {
        .unresolved(.init(link: link, type: .doc, location: location))
    }

    @available(*, unavailable, message: "Obsoleted in 0.10.0.")
    @inlinable public static func unresolved(
        ucf link: String,
        location: SourceLocation<Int32>?
    ) -> Self {
        .unresolved(.init(link: link, type: .ucf, location: location))
    }

    /// Creates a URL outline from a string, including the scheme.
    @inlinable public static func url(_ url: String, location: SourceLocation<Int32>?) -> Self {
        .unresolved(.init(link: url, type: .url, location: location))
    }
}
extension SymbolGraph.Outline {
    public enum CodingKey: String, Sendable {
        case unresolved_doc = "D"
        case unresolved_ucf = "U"
        case unresolved_url = "H"

        //  Obsoleted in 0.9.8.
        case unresolved_urlWithoutScheme = "W"

        case fragment = "F"
        case location = "L"
        case vector_self = "S"
        case vertex_self = "R"
        case text = "T"
    }
}
extension SymbolGraph.Outline: BSONDocumentEncodable {
    public func encode(to bson: inout BSON.DocumentEncoder<CodingKey>) {
        switch self {
        case .vector(let id, self: let heir, text: let text):
            bson[.vertex_self] = id
            bson[.vector_self] = heir
            bson[.text] = text

        case .vertex(let id, text: let text):
            bson[.vertex_self] = id
            bson[.text] = text

        case .symbol(let self):
            bson[.vertex_self] = self

        case .fragment(let self):
            bson[.fragment] = self

        case .location(let self):
            bson[.location] = self

        case .unresolved(let self):
            bson[.location] = self.location

            switch self.type {
            case .doc:  bson[.unresolved_doc] = self.link
            case .ucf:  bson[.unresolved_ucf] = self.link
            case .url:  bson[.unresolved_url] = self.link
            }
        }
    }
}
extension SymbolGraph.Outline: BSONDocumentDecodable {
    @inlinable public init(bson: BSON.DocumentDecoder<CodingKey>) throws {
        if  let id: Int32 = try bson[.vertex_self]?.decode() {
            if  let heir: Int32 = try bson[.vector_self]?.decode() {
                self = .vector(id, self: heir, text: try bson[.text].decode())
            } else if
                let text: SymbolGraph.OutlineText = try bson[.text]?.decode() {
                self = .vertex(id, text: text)
            } else {
                self = .symbol(id)
            }

            return
        } else if
            let fragment: String = try bson[.fragment]?.decode() {
            self = .fragment(fragment)
            return
        }

        let type: Unresolved.LinkType
        let link: String

        //  These are unscientifically ordered by likelihood.
        if  let text: String = try bson[.unresolved_ucf]?.decode() {
            type = .ucf
            link = text
        } else if
            let text: String = try bson[.unresolved_doc]?.decode() {
            type = .doc
            link = text
        } else if
            let text: String = try bson[.unresolved_url]?.decode() {
            type = .url
            link = text
        } else if
            let text: String = try bson[.unresolved_urlWithoutScheme]?.decode() {
            type = .url
            link = "https://\(text)"
        } else {
            self = .location(try bson[.location].decode())
            return
        }

        self = .unresolved(
            .init(
                link: link,
                type: type,
                location: try bson[.location]?.decode()
            )
        )
    }
}
