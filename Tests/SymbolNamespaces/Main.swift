import JSON
import SymbolNamespaces
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
                let namespace:SymbolNamespace = try .init(json: json)
                tests.expect(namespace.metadata.version ==? .v(0, 6, 0))
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
                let namespace:SymbolNamespace = try .init(json: json)
                tests.expect(namespace.metadata.version ==? .v(0, 6, 0))
            }
        }
        #endif
    }
}
