import MongoDB
import MongoTesting
import Symbols
@_spi(testable)
import UnidocDB
import UnidocRecords

struct Packages:MongoTestBattery
{
    typealias Configuration = Main.Configuration

    static
    func run(tests:TestGroup, pool:Mongo.SessionPool, database:Mongo.Database) async throws
    {
        let database:Unidoc.DB = .init(session: try await .init(from: pool), in: database)
        try await database.setup()

        do
        {
            let tests:TestGroup = tests ! "Indexing"
            await tests.do
            {
                for expected:(symbol:Symbol.Package, id:Unidoc.Package, new:Bool) in
                [
                    ("a", 0, true),
                    ("b", 1, true),
                    ("a", 0, false),
                    ("b", 1, false),
                    ("c", 2, true),
                    ("c", 2, false),
                    ("a", 0, false),
                    ("b", 1, false),
                ]
                {
                    let (package, new):(Unidoc.PackageMetadata, Bool) =
                        try await database.index(package: expected.symbol)

                    tests.expect(package.id ==? expected.id)
                    tests.expect(new ==? expected.new)
                }
            }
        }
        guard
        let tests:TestGroup = tests / "Aliasing"
        else
        {
            return
        }

        await tests.do
        {
            try await database.alias(existing: "a", package: "aa")

            try await database.alias(existing: "b", package: "bb")

            try await database.alias(existing: "c", package: "cc")
            try await database.alias(existing: "c", package: "cc")
            try await database.alias(existing: "cc", package: "ccc")
            try await database.alias(existing: "cc", package: "ccc")
        }

        guard
        let tests:TestGroup = tests / "Reindexing"
        else
        {
            return
        }

        await tests.do
        {
            for (queried, expected):
                (Symbol.Package, (symbol:Symbol.Package, id:Unidoc.Package)) in
            [
                ("a", ("a", 0)),
                ("b", ("b", 1)),
                ("c", ("c", 2)),
                ("aa", ("a", 0)),
                ("bb", ("b", 1)),
                ("cc", ("c", 2)),
                ("ccc", ("c", 2)),
            ]
            {
                let (package, new):(Unidoc.PackageMetadata, Bool) = try await database.index(
                    package: queried)

                tests.expect(package.symbol ==? expected.symbol)
                tests.expect(package.id ==? expected.id)
                tests.expect(false: new)
            }
        }
    }
}
