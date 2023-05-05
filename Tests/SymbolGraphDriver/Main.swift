import BSONDecoding
import SymbolGraphs
import SymbolGraphDriver
import System
import Testing

@main
enum Main:SyncTests
{
    static
    func run(tests:Tests)
    {
        // #if !DEBUG
        if  let tests:TestGroup = tests / "standard-library",
            let graph:SymbolGraph = (tests.do
            {
                try Driver.build(
                    metadata: .swift(at: .version(.v(5, 8, 0))),
                    parts:
                    [
                        "TestModules/Symbolgraphs/Swift.symbols.json",
                    ])
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
