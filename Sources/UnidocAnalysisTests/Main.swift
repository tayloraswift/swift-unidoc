import BSONTesting
import Unidoc
import UnidocAnalysis
import UnidocRecords

@main
enum Main:SyncTests
{
    static
    func run(tests:Tests)
    {
        if  let tests:TestGroup = tests / "TypeTree" / "Sorting"
        {
            enum swift
            {
                static
                var id:Unidoc.Zone = .init(package: 0, version: 0)

                enum Swift
                {
                    static
                    var id:Unidoc.Scalar { swift.id + 0 * .module }

                    enum Int
                    {
                        static
                        var id:Unidoc.Scalar { swift.id + 0 * .decl }
                    }
                }
            }
            enum swift_malibu
            {
                static
                var id:Unidoc.Zone = .init(package: 1, version: 2)

                enum BarbieCore
                {
                    static
                    var id:Unidoc.Scalar { swift_malibu.id + 0 * .module }

                    enum Barbie
                    {
                        static
                        var id:Unidoc.Scalar { swift_malibu.id + 0 * .decl }
                    }
                }
            }
            let culture:Unidoc.Scalar = swift_malibu.id + 1 * .module
            let records:Volume = .init(latest: nil,
                masters:
                [
                    .culture(.init(id: swift_malibu.BarbieCore.id,
                        module: .init(name: "BarbieCore", type: .regular))),

                    .decl(.init(id: swift_malibu.BarbieCore.Barbie.id,
                        flags: .init(phylum: .struct, kinks: [], route: .unhashed),
                        signature: .init(),
                        symbol: .init(.s, ascii: "a"),
                        stem: "BarbieCore Barbie",
                        namespace: swift_malibu.BarbieCore.id,
                        culture: swift_malibu.BarbieCore.id,
                        scope: [])),

                    .decl(.init(id: swift_malibu.id + 1 * .decl,
                        flags: .init(phylum: .struct, kinks: [], route: .unhashed),
                        signature: .init(),
                        symbol: .init(.s, ascii: "b"),
                        stem: "Swift Int DollRepresentation",
                        namespace: swift.Swift.id,
                        culture: culture,
                        scope: [swift.Swift.Int.id])),

                    .decl(.init(id: swift_malibu.id + 2 * .decl,
                        flags: .init(phylum: .struct, kinks: [], route: .unhashed),
                        signature: .init(),
                        symbol: .init(.s, ascii: "c"),
                        stem: "Swift Int DollIterator",
                        namespace: swift.Swift.id,
                        culture: culture,
                        scope: [swift.Swift.Int.id])),

                    .decl(.init(id: swift_malibu.id + 3 * .decl,
                        flags: .init(phylum: .struct, kinks: [], route: .unhashed),
                        signature: .init(),
                        symbol: .init(.s, ascii: "d"),
                        stem: "BarbieCore Barbie PlasticKeychain",
                        namespace: swift_malibu.BarbieCore.id,
                        culture: culture,
                        scope: [swift_malibu.BarbieCore.Barbie.id])),

                    .decl(.init(id: swift_malibu.id + 4 * .decl,
                        flags: .init(phylum: .struct, kinks: [], route: .unhashed),
                        signature: .init(),
                        symbol: .init(.s, ascii: "e"),
                        stem: "BarbieCore Barbie ID",
                        namespace: swift_malibu.BarbieCore.id,
                        culture: culture,
                        scope: [swift_malibu.BarbieCore.Barbie.id])),

                    .decl(.init(id: swift_malibu.id + 5 * .decl,
                        flags: .init(phylum: .struct, kinks: [], route: .unhashed),
                        signature: .init(),
                        symbol: .init(.s, ascii: "f"),
                        stem: "BarbieHousing Raquelle",
                        namespace: culture,
                        culture: culture,
                        scope: [])),

                    .decl(.init(id: swift_malibu.id + 6 * .decl,
                        flags: .init(phylum: .struct, kinks: [], route: .unhashed),
                        signature: .init(),
                        symbol: .init(.s, ascii: "g"),
                        stem: "BarbieHousing Raquelle PlasticKeychain",
                        namespace: culture,
                        culture: culture,
                        scope: [swift_malibu.id + 4 * .decl])),

                    .decl(.init(id: swift_malibu.id + 7 * .decl,
                        flags: .init(phylum: .struct, kinks: [], route: .unhashed),
                        signature: .init(),
                        symbol: .init(.s, ascii: "h"),
                        stem: "BarbieHousing Raquelle ID",
                        namespace: culture,
                        culture: culture,
                        scope: [swift_malibu.id + 4 * .decl])),
                ],
                groups: [],
                names: .init(id: swift_malibu.id,
                    display: nil,
                    refname: nil,
                    origin: nil,
                    volume: .init(
                        package: "swift-malibu",
                        version: "master"),
                    latest: true,
                    patch: nil))

            let (_, trees):(_, [Volume.TypeTree]) = records.indexes()
            if  let tree:Volume.TypeTree = tests.expect(value: trees.first { $0.id == culture })
            {
                tests.expect(tree ==? .init(id: culture, rows:
                    [
                        .init(stem: "BarbieCore Barbie", same: .package),
                        .init(stem: "BarbieCore Barbie ID", same: .culture),
                        .init(stem: "BarbieCore Barbie PlasticKeychain", same: .culture),
                        .init(stem: "BarbieHousing Raquelle", same: .culture),
                        .init(stem: "BarbieHousing Raquelle ID", same: .culture),
                        .init(stem: "BarbieHousing Raquelle PlasticKeychain", same: .culture),
                        .init(stem: "Swift Int", same: nil),
                        .init(stem: "Swift Int DollIterator", same: .culture),
                        .init(stem: "Swift Int DollRepresentation", same: .culture),
                    ]))
            }
        }
        if  let tests:TestGroup = tests / "TypeTree" / "RoundTripping"
        {
            let id:Unidoc.Scalar = .init(package: 1, version: 2, citizen: 3)

            if  let tests:TestGroup = tests / "Empty",
                    tests.roundtrip(Volume.TypeTree.init(id: id, rows: []))
            {
            }
            if  let tests:TestGroup = tests / "One",
                    tests.roundtrip(Volume.TypeTree.init(id: id, rows:
                    [
                        .init(stem: "CryptoKit BTC"),
                    ]))
            {
            }
            if  let tests:TestGroup = tests / "Many",
                    tests.roundtrip(Volume.TypeTree.init(id: id, rows:
                    [
                        .init(stem: "CryptoKit BTC"),
                        .init(stem: "CryptoKit ETH"),
                        .init(stem: "CryptoKit ETH Classic"),
                        .init(stem: "CryptoKit SOL"),
                    ]))
            {
            }
            if  let tests:TestGroup = tests / "Hashed",
                    tests.roundtrip(Volume.TypeTree.init(id: id, rows:
                    [
                        .init(stem: "CryptoKit BTC"),
                        .init(stem: "CryptoKit ETH"),
                        .init(stem: "CryptoKit ETH Classic"),
                        .init(stem: "CryptoKit ETH Classic\tinit(_:)",
                            hash: .init(hashing: "moist")),
                        .init(stem: "CryptoKit ETH Classic\tinit(_:)",
                            hash: .init(hashing: "the’ir")),
                        .init(stem: "CryptoKit SOL"),
                    ]))
            {
            }
            if  let tests:TestGroup = tests / "Races",
                    tests.roundtrip(Volume.TypeTree.init(id: id, rows:
                    [
                        .init(stem: "CryptoKit ETH Classic\tinit(_:)",
                            hash: .init(hashing: "the’ir"),
                            same: .culture),
                        .init(stem: "CryptoCore BTC\tinit(_:)",
                            hash: .init(hashing: "the’ir"),
                            same: .package),
                    ]))
            {
            }
        }
    }
}
