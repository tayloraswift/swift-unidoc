import BSONTesting
import Unidoc
import UnidocRecords

@main
enum Main:TestMain, TestBattery
{
    static
    func run(tests:TestGroup)
    {
        if  let tests:TestGroup = tests / "TypeTree" / "RoundTripping"
        {
            let id:Unidoc.Scalar = .init(package: 1, version: 2, citizen: 3)

            if  let tests:TestGroup = tests / "Empty",
                    tests.roundtrip(Unidoc.TypeTree.init(id: id, rows: []))
            {
            }
            if  let tests:TestGroup = tests / "One",
                    tests.roundtrip(Unidoc.TypeTree.init(id: id, rows:
                    [
                        .decl("CryptoKit BTC"),
                    ]))
            {
            }
            if  let tests:TestGroup = tests / "Many",
                    tests.roundtrip(Unidoc.TypeTree.init(id: id, rows:
                    [
                        .decl("CryptoKit BTC"),
                        .decl("CryptoKit ETH"),
                        .decl("CryptoKit ETH Classic"),
                        .decl("CryptoKit SOL"),
                    ]))
            {
            }
            if  let tests:TestGroup = tests / "Hashed",
                    tests.roundtrip(Unidoc.TypeTree.init(id: id, rows:
                    [
                        .decl("CryptoKit BTC"),
                        .decl("CryptoKit ETH"),
                        .decl("CryptoKit ETH Classic"),
                        .decl("CryptoKit ETH Classic\tinit(_:)",
                            language: .c,
                            phylum: .initializer,
                            hash: .init(hashing: "moist")),
                        .decl("CryptoKit ETH Classic\tinit(_:)",
                            phylum: .initializer,
                            hash: .init(hashing: "the’ir")),
                        .decl("CryptoKit SOL"),
                    ]))
            {
            }
            if  let tests:TestGroup = tests / "Stems",
                    tests.roundtrip(Unidoc.TypeTree.init(id: id, rows:
                    [
                        .decl("CryptoKit ETH Classic\tinit(_:)",
                            phylum: .initializer,
                            hash: .init(hashing: "the’ir"),
                            from: .culture),
                        .decl("CryptoCore BTC\tinit(_:)",
                            phylum: .initializer,
                            hash: .init(hashing: "the’ir"),
                            from: .package),
                    ]))
            {
            }
            if  let tests:TestGroup = tests / "CustomText",
                    tests.roundtrip(Unidoc.TypeTree.init(id: id, rows:
                    [
                        .article("CryptoKit Getting-Started",
                            text: "Getting Started",
                            hash: .init(hashing: "Getting-Started")),
                        .article("CryptoCore Weird-Title",
                            text: "\u{00}\u{FF}"),
                        .article("CryptoCore Weird-Title-With-Hash",
                            text: "\u{00}\u{FF}",
                            hash: .init(hashing: "Weird-Title-With-Hash")),
                    ]))
            {
            }
        }
    }
}
