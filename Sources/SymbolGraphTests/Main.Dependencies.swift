import BSON
import SymbolGraphs
import Testing

extension Main
{
    struct Dependencies
    {
    }
}
extension Main.Dependencies:TestBattery
{
    static
    func run(tests:TestGroup)
    {
        for (name, value):(String, SymbolGraphMetadata.Dependency) in
        [
            (
                "Semver",
                .init(package: "swift-example",
                    requirement: .exact(.v(1, 2, 3)),
                    revision: 0xabcd1234,
                    version: .stable(.release(.v(1, 2, 3))))
            ),
            (
                "Branch",
                .init(package: "swift-example",
                    requirement: nil,
                    revision: 0xabcd1234,
                    version: "master")
            )
        ]
        {
            guard let tests:TestGroup = tests / name
            else
            {
                continue
            }

            tests.do
            {
                let encoded:BSON.Document = .init(encoding: value)
                let decoded:SymbolGraphMetadata.Dependency = try .init(
                    bson: BSON.DocumentView<[UInt8]>.init(encoded))

                tests.expect(value ==? decoded)
            }
        }
    }
}
