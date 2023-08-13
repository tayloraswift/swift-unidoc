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
        if  let tests:TestGroup = tests / "TypeTree"
        {
            let id:Unidoc.Scalar = .init(package: 1, version: 2, citizen: 3)

            if  let tests:TestGroup = tests / "Empty",
                    tests.roundtrip(Record.TypeTree.init(id: id, rows: []))
            {
            }
            if  let tests:TestGroup = tests / "One",
                    tests.roundtrip(Record.TypeTree.init(id: id, rows:
                    [
                        .init(stem: "CryptoKit BTC", hash: nil, top: true),
                    ]))
            {
            }
            if  let tests:TestGroup = tests / "Many",
                    tests.roundtrip(Record.TypeTree.init(id: id, rows:
                    [
                        .init(stem: "CryptoKit BTC", hash: nil, top: true),
                        .init(stem: "CryptoKit ETH", hash: nil, top: true),
                        .init(stem: "CryptoKit ETH Classic", hash: nil, top: false),
                        .init(stem: "CryptoKit SOL", hash: nil, top: true),
                    ]))
            {
            }
            if  let tests:TestGroup = tests / "Hashed",
                    tests.roundtrip(Record.TypeTree.init(id: id, rows:
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
