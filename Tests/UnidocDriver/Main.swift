import BSONDecoding
import SymbolGraphs
import System
import Testing
import UnidocDriver

@main
enum Main:AsyncTests
{
    static
    func run(tests:Tests) async
    {
        // #if !DEBUG
        if  let tests:TestGroup = tests / "standard-library",
            let archive:DocumentationArchive = (await tests.do
            {
                let artifacts:DocumentationArtifacts = .init(
                    metadata: .swift(triple: .init("x86_64", "unknown", "linux", "gnu"),
                        ref: .version(.v(5, 8, 0))),
                    cultures:
                    [
                        try .init(
                            parts: ["TestModules/Symbolgraphs/Swift.symbols.json"],
                            node: .init(name: "Swift")),
                    ])
                return try await artifacts.build()
            })
        {
            let bson:BSON.Document = .init(encoding: archive)

            if  let tests:TestGroup = tests / "roundtripping"
            {
                tests.do
                {
                    //  Check that we can round-trip the symbolgraphs.
                    let decoded:DocumentationArchive = try .init(bson: .init(bson))
                    //tests.expect(decoded.metadata ==? graph.metadata)
                    tests.expect(decoded.files ==? archive.files)
                    tests.expect(decoded.graph ==? archive.graph)
                }
            }

            print("size:", bson.bytes.count)
        }
        // #endif
    }
}
