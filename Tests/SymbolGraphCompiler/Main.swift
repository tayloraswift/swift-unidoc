import Symbols
import SymbolGraphCompiler
import SymbolGraphParts
import System
import Testing

@main
enum Main:SyncTests
{
    static
    func run(tests:Tests)
    {
        if  let tests:TestGroup = tests / "extensions"
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
                var compiler:Compiler = .init(root: "/swift/swift-unidoc/TestModules")
                try compiler.compile(parts: tests.load(parts:
                    filenames.map 
                    {
                        ("TestModules/Symbolgraphs" as FilePath).appending("\($0).symbols.json")
                    }))
                
                if  let tests:TestGroup = tests / "locations"
                {
                    for scalar:Compiler.Scalar in compiler.scalars.load().local
                    {
                        if  let location:SourceLocation<FileSymbol> = tests.expect(
                                value: scalar.location)
                        {
                            tests.expect(true: location.file.path.starts(with: "Snippets/"))
                        }
                    }
                }
            }
        }
        #if !DEBUG
        if  let tests:TestGroup = tests / "standard-library"
        {
            tests.do
            {
                var compiler:Compiler = .init(root: "/")
                try compiler.compile(parts: tests.load(
                    parts: ["TestModules/Symbolgraphs/Swift.symbols.json"]))
            }
        }
        #endif
    }
}
