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
        if  let tests:TestGroup = tests / "NounTree" / "Sorting"
        {
            let culture:Unidoc.Scalar = .init(package: 1, version: 2, citizen: 0)
            let records:Records = .init(latest: nil,
                masters:
                [
                    "BarbieCore Barbie",
                    "BarbieCore Raquelle PlasticKeychain",
                    "BarbieCore Barbie PlasticKeychain",
                    "BarbieCore Barbie ID",
                    "BarbieCore Raquelle",
                    "BarbieCore Raquelle ID",
                ].map
                {
                    .decl(.init(id: culture.zone + 0 * .decl,
                        flags: .init(
                            phylum: .struct,
                            kinks: [],
                            route: .unhashed),
                        signature: .init(),
                        symbol: .init(.s, ascii: ""),
                        stem: $0,
                        superforms: [],
                        namespace: culture,
                        culture: culture,
                        scope: []))
                },
                groups: [],
                zone: .init(id: .init(package: 1, version: 2),
                    package: "swift-example",
                    version: "master",
                    refname: nil,
                    display: nil,
                    github: nil,
                    latest: true,
                    patch: nil))

            let (_, trees):(Record.NounMap, [Record.NounTree]) = records.indexes()
            if  let tree:Record.NounTree = tests.expect(value: trees.first)
            {
                tests.expect(tree ==? .init(id: culture, rows:
                    [
                        .init(stem: "BarbieCore Barbie", top: true),
                        .init(stem: "BarbieCore Barbie ID", top: false),
                        .init(stem: "BarbieCore Barbie PlasticKeychain", top: false),
                        .init(stem: "BarbieCore Raquelle", top: true),
                        .init(stem: "BarbieCore Raquelle ID", top: false),
                        .init(stem: "BarbieCore Raquelle PlasticKeychain", top: false),
                    ]))
            }
        }
        if  let tests:TestGroup = tests / "NounTree" / "RoundTripping"
        {
            let id:Unidoc.Scalar = .init(package: 1, version: 2, citizen: 3)

            if  let tests:TestGroup = tests / "Empty",
                    tests.roundtrip(Record.NounTree.init(id: id, rows: []))
            {
            }
            if  let tests:TestGroup = tests / "One",
                    tests.roundtrip(Record.NounTree.init(id: id, rows:
                    [
                        .init(stem: "CryptoKit BTC", hash: nil, top: true),
                    ]))
            {
            }
            if  let tests:TestGroup = tests / "Many",
                    tests.roundtrip(Record.NounTree.init(id: id, rows:
                    [
                        .init(stem: "CryptoKit BTC", hash: nil, top: true),
                        .init(stem: "CryptoKit ETH", hash: nil, top: true),
                        .init(stem: "CryptoKit ETH Classic", hash: nil, top: false),
                        .init(stem: "CryptoKit SOL", hash: nil, top: true),
                    ]))
            {
            }
            if  let tests:TestGroup = tests / "Hashed",
                    tests.roundtrip(Record.NounTree.init(id: id, rows:
                    [
                        .init(stem: "CryptoKit BTC", hash: nil, top: true),
                        .init(stem: "CryptoKit ETH", hash: nil, top: true),
                        .init(stem: "CryptoKit ETH Classic", hash: nil, top: false),
                        .init(stem: "CryptoKit ETH Classic\tinit(_:)",
                            hash: .init(hashing: "moist"),
                            top: false),
                        .init(stem: "CryptoKit ETH Classic\tinit(_:)",
                            hash: .init(hashing: "the’ir"),
                            top: false),
                        .init(stem: "CryptoKit SOL", hash: nil, top: true),
                    ]))
            {
            }
        }
    }
}
