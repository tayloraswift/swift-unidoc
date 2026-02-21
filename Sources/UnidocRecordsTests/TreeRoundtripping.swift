import BSON
import Testing
import Unidoc
import UnidocRecords

@Suite struct TreeRoundtripping {
    private var id: Unidoc.Scalar { .init(package: 1, version: 2, citizen: 3) }

    @Test func empty() throws {
        try Self.roundtrip(Unidoc.TypeTree.init(id: self.id, rows: []))
    }

    @Test func one() throws {
        try Self.roundtrip(
            Unidoc.TypeTree.init(
                id: self.id, rows: [
                    .decl("CryptoKit BTC"),
                ]
            )
        )
    }

    @Test func many() throws {
        try Self.roundtrip(
            Unidoc.TypeTree.init(
                id: self.id, rows: [
                    .decl("CryptoKit BTC"),
                    .decl("CryptoKit ETH"),
                    .decl("CryptoKit ETH Classic"),
                    .decl("CryptoKit SOL"),
                ]
            )
        )
    }

    @Test func hashed() throws {
        try Self.roundtrip(
            Unidoc.TypeTree.init(
                id: self.id, rows: [
                    .decl("CryptoKit BTC"),
                    .decl("CryptoKit ETH"),
                    .decl("CryptoKit ETH Classic"),
                    .decl(
                        "CryptoKit ETH Classic\tinit(_:)",
                        language: .c,
                        phylum: .initializer,
                        hash: .init(hashing: "moist")
                    ),
                    .decl(
                        "CryptoKit ETH Classic\tinit(_:)",
                        phylum: .initializer,
                        hash: .init(hashing: "the’ir")
                    ),
                    .decl("CryptoKit SOL"),
                ]
            )
        )
    }

    @Test func stems() throws {
        try Self.roundtrip(
            Unidoc.TypeTree.init(
                id: self.id, rows: [
                    .decl(
                        "CryptoKit ETH Classic\tinit(_:)",
                        phylum: .initializer,
                        hash: .init(hashing: "the’ir"),
                        from: .culture
                    ),
                    .decl(
                        "CryptoCore BTC\tinit(_:)",
                        phylum: .initializer,
                        hash: .init(hashing: "the’ir"),
                        from: .package
                    ),
                ]
            )
        )
    }

    @Test func customText() throws {
        try Self.roundtrip(
            Unidoc.TypeTree.init(
                id: self.id, rows: [
                    .article(
                        "CryptoKit Getting-Started",
                        text: "Getting Started",
                        hash: .init(hashing: "Getting-Started")
                    ),
                    .article(
                        "CryptoCore Weird-Title",
                        text: "\u{00}\u{FF}"
                    ),
                    .article(
                        "CryptoCore Weird-Title-With-Hash",
                        text: "\u{00}\u{FF}",
                        hash: .init(hashing: "Weird-Title-With-Hash")
                    ),
                ]
            )
        )
    }
}
extension TreeRoundtripping {
    private static func roundtrip<Codable>(_ codable: Codable) throws
        where Codable: BSONDocumentDecodable & BSONDocumentEncodable & Equatable {
        let encoded: BSON.Document = .init(encoding: codable)
        let decoded: Codable = try .init(bson: encoded)
        #expect(decoded == codable)
    }
}
