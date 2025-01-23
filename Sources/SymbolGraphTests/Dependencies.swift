import BSON
import SymbolGraphs
import Testing

struct Dependencies
{
    @Test(arguments: [
            .init(package: .init(name: "swift-example"),
                requirement: .exact(.release(.v(1, 2, 3))),
                revision: 0xabcd1234,
                version: .stable(.release(.v(1, 2, 3)))),
            .init(package: .init(name: "swift-example"),
                requirement: nil,
                revision: 0xabcd1234,
                version: "master"),
        ] as [SymbolGraphMetadata.Dependency])
    static func Dependency(_ value:SymbolGraphMetadata.Dependency) throws
    {
        let encoded:BSON.Document = .init(encoding: value)
        let decoded:SymbolGraphMetadata.Dependency = try .init(bson: encoded)

        #expect(value == decoded)
    }
}
