import SymbolDescriptions
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
                var compiler:Compiler = .init(root: "/swift/swift-unidoc/TestModules")
                try compiler.compile(colonies: tests.load(colonies:
                    filenames.map 
                    {
                        ("TestModules/Symbolgraphs" as FilePath).appending("\($0).symbols.json")
                    }))
                
                if  let tests:TestGroup = tests / "locations"
                {
                    for scalar:Compiler.Scalar in compiler.scalars.load()
                    {
                        if  let location:SourceLocation<FileIdentifier> = tests.expect(
                                value: scalar.location)
                        {
                            tests.expect(true: location.file.path.starts(with: "Snippets/"))
                        }
                    }
                }
            }
        }
    }
}
