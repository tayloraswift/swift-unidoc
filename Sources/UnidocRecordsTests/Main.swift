import BSONTesting
import Unidoc
import UnidocRecords

@main
enum Main:SyncTests
{
    static
    func run(tests:Tests)
    {
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
            if  let tests:TestGroup = tests / "Stems",
                    tests.roundtrip(Volume.TypeTree.init(id: id, rows:
                    [
                        .init(stem: "CryptoKit ETH Classic\tinit(_:)",
                            hash: .init(hashing: "the’ir"),
                            from: .culture),
                        .init(stem: "CryptoCore BTC\tinit(_:)",
                            hash: .init(hashing: "the’ir"),
                            from: .package),
                    ]))
            {
            }
            if  let tests:TestGroup = tests / "CustomText",
                    tests.roundtrip(Volume.TypeTree.init(id: id, rows:
                    [
                        .init(stem: "CryptoKit Getting-Started",
                            hash: .init(hashing: "Getting-Started"),
                            text: "Getting Started"),
                        .init(stem: "CryptoCore Weird-Title",
                            text: "\u{00}\u{FF}"),
                        .init(stem: "CryptoCore Weird-Title-With-Hash",
                            hash: .init(hashing: "Weird-Title-With-Hash"),
                            text: "\u{00}\u{FF}"),
                    ]))
            {
            }
        }
    }
}
