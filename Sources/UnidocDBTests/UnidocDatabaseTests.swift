import MongoDB
import MongoTesting
import SemanticVersions
import SymbolGraphs
import Symbols
import Testing
import UnidocDB
import UnidocTesting

@Suite(.tags(.database)) struct UnidocDatabaseTests {
    /// We should be able to reinitialize the database as many times as we want.
    /// (Initialization should be idempotent.)
    @Test static func Setup() async throws {
        try await Mongo.DriverBootstrap.unidoc.withSessionPool(logger: .init(level: .error)) {
            let database: Mongo.Database = "DatabaseSetup"
            try await $0.withTemporaryDatabase(database) {
                let session: Mongo.Session = try await .init(from: $0)

                try await Unidoc.DB.init(session: session, in: database).setup()
                try await Unidoc.DB.init(session: session, in: database).setup()
                try await Unidoc.DB.init(session: session, in: database).setup()
            }
        }
    }

    @Test static func PackageAliasing() async throws {
        let database: Mongo.Database = "Packages"
        try await database.withTemporaryUnidocDatabase { (unidoc: Unidoc.DB) in
            for expected: (symbol: Symbol.Package, id: Unidoc.Package, new: Bool) in [
                    ("a", 0, true),
                    ("b", 1, true),
                    ("a", 0, false),
                    ("b", 1, false),
                    ("c", 2, true),
                    ("c", 2, false),
                    ("a", 0, false),
                    ("b", 1, false),
                ] {
                let (package, new): (Unidoc.PackageMetadata, Bool) = try await unidoc.index(
                    package: expected.symbol
                )

                #expect(package.id == expected.id)
                #expect(new == expected.new)
            }

            try await unidoc.alias(existing: "a", package: "aa")

            try await unidoc.alias(existing: "b", package: "bb")

            try await unidoc.alias(existing: "c", package: "cc")
            try await unidoc.alias(existing: "c", package: "cc")
            try await unidoc.alias(existing: "cc", package: "ccc")
            try await unidoc.alias(existing: "cc", package: "ccc")

            for (queried, (symbol, id)):
                (Symbol.Package, (Symbol.Package, Unidoc.Package)) in [
                    ("a", ("a", 0)),
                    ("b", ("b", 1)),
                    ("c", ("c", 2)),
                    ("aa", ("a", 0)),
                    ("bb", ("b", 1)),
                    ("cc", ("c", 2)),
                    ("ccc", ("c", 2)),
                ] {
                let (package, new): (Unidoc.PackageMetadata, Bool) = try await unidoc.index(
                    package: queried
                )

                #expect(package.symbol == symbol)
                #expect(package.id == id)
                #expect(!new)
            }
        }
    }

    @Test static func SymbolGraphs() async throws {
        let database: Mongo.Database = "SymbolGraphs"
        try await database.withTemporaryUnidocDatabase { (unidoc: Unidoc.DB) in
            let triple: Symbol.Triple = .x86_64_unknown_linux_gnu
            let empty: SymbolGraph = .init(modules: [])

            var docs: SymbolGraphObject<Void>

            do {
                docs = .init(
                    metadata: .init(
                        package: .init(scope: "apple", name: .swift),
                        commit: .init(name: "swift-5.8.1-RELEASE"),
                        triple: triple,
                        swift: .init(version: .v(5, 8, 1)),
                        products: []
                    ),
                    graph: empty
                )

                #expect(
                    try await unidoc.store(docs: docs) == .init(
                        edition: .init(package: 0, version: 0),
                        updated: false
                    ),
                    "InsertVersionedSwift"
                )
            }
            do {
                docs.metadata.package.scope = "orange"
                docs.metadata.package.name = "swift-not-named-swift"
                docs.metadata.commit = nil

                #expect(
                    try await unidoc.store(docs: docs) == .init(
                        edition: .init(package: 1, version: -1),
                        updated: false
                    ),
                    "InsertLocalSwift"
                )
            }
            do {
                docs.metadata.commit = .init(
                    name: "1.2.3",
                    sha1: 0xffffffffffffffffffffffffffffffffffffffff
                )

                #expect(
                    try await unidoc.store(docs: docs) == .init(
                        edition: .init(package: 1, version: 0),
                        updated: false
                    ),
                    "InsertRelease"
                )
            }
            do {

                docs.metadata.commit = .init(
                    name: "2.0.0-beta1",
                    sha1: 0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
                )

                #expect(
                    try await unidoc.store(docs: docs) == .init(
                        edition: .init(package: 1, version: 1),
                        updated: false
                    ),
                    "InsertPrerelease"
                )
            }
            do {
                docs.metadata.commit = nil

                #expect(
                    try await unidoc.store(docs: docs) == .init(
                        edition: .init(package: 1, version: -1),
                        updated: true
                    ),
                    "UpdateLocal"
                )
            }
            do {
                docs.metadata.commit = .init(
                    name: "2.0.0-beta1",
                    sha1: 0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
                )

                #expect(
                    try await unidoc.store(docs: docs) == .init(
                        edition: .init(package: 1, version: 1),
                        updated: true
                    ),
                    "UpdatePrerelease"
                )
            }
            do {
                docs.metadata.commit = .init(
                    name: "1.2.3",
                    sha1: 0xffffffffffffffffffffffffffffffffffffffff
                )

                #expect(
                    try await unidoc.store(docs: docs) == .init(
                        edition: .init(package: 1, version: 0),
                        updated: true
                    ),
                    "UpdateRelease"
                )
            }
            do {
                try await unidoc.alias(
                    existing: docs.metadata.package.id,
                    package: docs.metadata.package.name
                )

                docs.metadata.package.scope = nil

                #expect(
                    try await unidoc.store(docs: docs) == .init(
                        edition: .init(package: 1, version: 0),
                        updated: true
                    ),
                    "UpdateReleaseUnscoped"
                )
            }
            do {
                docs.metadata.package.scope = "banana"

                #expect(
                    try await unidoc.store(docs: docs) == .init(
                        edition: .init(package: 2, version: 0),
                        updated: false
                    ),
                    "InsertReleaseWithDifferentScope"
                )
            }
        }
    }
}
