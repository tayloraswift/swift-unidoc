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
            let graph:SymbolGraph = (await tests.do
            {
                let artifacts:Driver.Artifacts = .init(
                    metadata: .swift(at: .version(.v(5, 8, 0))),
                    cultures:
                    [
                        try .init(module: "Swift",
                            parts:
                            [
                                "TestModules/Symbolgraphs/Swift.symbols.json",
                            ]),
                    ])
                return try await artifacts.buildSymbolGraph()
            })
        {
            let bson:BSON.Document = .init(encoding: graph)

            if  let tests:TestGroup = tests / "roundtripping"
            {
                tests.do
                {
                    //  Check that we can round-trip the symbolgraphs.
                    let decoded:SymbolGraph = try .init(bson: .init(bson))
                    //tests.expect(decoded.metadata ==? graph.metadata)
                    tests.expect(decoded.files ==? graph.files)
                    tests.expect(decoded.nodes ==? graph.nodes)
                }
            }

            print("size:", bson.bytes.count)
        }
        // #endif
    }
}
