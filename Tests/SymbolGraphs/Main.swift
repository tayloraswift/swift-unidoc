import JSON
import SymbolGraphs
import System
import Testing

@main
enum Main:SyncTests
{
    static
    func run(tests:Tests)
    {
        if  let tests:TestGroup = tests / "protocols"
        {
            tests.do
            {
                let filepath:FilePath = ".zoo/ZooProtocols.symbols.json"
                let file:[UInt8] = try filepath.read()

                let json:JSON.Object = try .init(parsing: file)
                let symbols:SymbolGraph = try .init(merging: [json])

                tests.expect(symbols.format ==? .init(0, 6, 0))
            }
        }
    }
}
