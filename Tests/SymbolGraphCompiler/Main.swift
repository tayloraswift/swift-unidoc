import SymbolColonies
import SymbolGraphCompiler
import System
import Testing

@main
enum Main:SyncTests
{
    static
    func run(tests:Tests)
    {
        if  let tests:TestGroup = tests / "main"
        {
            let filenames:[String] =
            [
                "ExternalExtensionsWithConformances",
                "ExternalExtensionsWithConformances@ExtendableTypesWithConstraints",
                "ExternalExtensionsWithConstraints",
                "ExternalExtensionsWithConstraints@ExtendableTypesWithConstraints",
                "InternalExtensionsWithConformances",
                "InternalExtensionsWithConstraints",
            ]
            tests.do
            {
                var compiler:Compiler = .init()
                try compiler.compile(colonies: tests.load(colonies:
                    filenames.map 
                    {
                        ("TestModules/Symbolgraphs" as FilePath).appending("\($0).symbols.json")
                    }))
            }
        }
    }
}
