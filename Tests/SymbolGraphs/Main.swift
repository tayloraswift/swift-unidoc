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
                let filepath:FilePath = "TestModules/Symbolgraphs/Protocols.symbols.json"
                let file:[UInt8] = try filepath.read()

                let json:JSON.Object = try .init(parsing: file)
                do
                {
                    let symbols:SymbolGraph = try .init(merging: [json])
                    tests.expect(symbols.format ==? .v(0, 6, 0))
                }
                catch let error
                {
                    throw error
                }
            }
        }
        #if !DEBUG
        if  let tests:TestGroup = tests / "stdlib"
        {
            tests.do
            {
                let filepath:FilePath = "TestModules/Symbolgraphs/Swift.symbols.json"
                let file:[UInt8] = try filepath.read()

                let json:JSON.Object = try .init(parsing: file)
                do
                {
                    let symbols:SymbolGraph = try .init(merging: [json])
                    tests.expect(symbols.format ==? .init(0, 6, 0))
                }
                catch let error
                {
                    throw error
                }
            }
        }
        #endif
    }
}
