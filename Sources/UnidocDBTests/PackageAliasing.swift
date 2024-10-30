import MongoDB
import Symbols
import Testing
@_spi(testable)
import UnidocDB
import UnidocRecords
import UnidocTesting

@Suite
struct PackageAliasing:Unidoc.TestBattery
{
    @Test
    func packages() async throws
    {
        try await self.run(in: "Packages")
    }

    func run(with unidoc:Unidoc.DB) async throws
    {
        for expected:(symbol:Symbol.Package, id:Unidoc.Package, new:Bool) in [
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
            let (package, new):(Unidoc.PackageMetadata, Bool) = try await unidoc.index(
                package: expected.symbol)

            #expect(package.id == expected.id)
            #expect(new == expected.new)
        }

        try await unidoc.alias(existing: "a", package: "aa")

        try await unidoc.alias(existing: "b", package: "bb")

        try await unidoc.alias(existing: "c", package: "cc")
        try await unidoc.alias(existing: "c", package: "cc")
        try await unidoc.alias(existing: "cc", package: "ccc")
        try await unidoc.alias(existing: "cc", package: "ccc")

        for (queried, expected):
            (Symbol.Package, (symbol:Symbol.Package, id:Unidoc.Package)) in [
            ("a", ("a", 0)),
            ("b", ("b", 1)),
            ("c", ("c", 2)),
            ("aa", ("a", 0)),
            ("bb", ("b", 1)),
            ("cc", ("c", 2)),
            ("ccc", ("c", 2)),
        ]
        {
            let (package, new):(Unidoc.PackageMetadata, Bool) = try await unidoc.index(
                package: queried)

            #expect(package.symbol == expected.symbol)
            #expect(package.id == expected.id)
            #expect(!new)
        }
    }
}
