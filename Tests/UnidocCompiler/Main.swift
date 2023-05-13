import Symbols
import SymbolGraphParts
import System
import Testing
import UnidocCompiler

@main
enum Main:SyncTests
{
    static
    func run(tests:Tests)
    {
        if  let tests:TestGroup = tests / "extensions"
        {
            tests.do
            {
                var compiler:Compiler = .init(root: "/swift/swift-unidoc/TestModules")

                let directory:FilePath = "TestModules/Symbolgraphs"
                for culture:[FilePath] in
                [
                    [
                        "ExternalExtensionsWithConformances",
                        "ExternalExtensionsWithConformances@ExtendableTypesWithConstraints",
                    ],
                    [
                        "ExternalExtensionsWithConstraints",
                        "ExternalExtensionsWithConstraints@ExtendableTypesWithConstraints",
                    ],
                    [
                        "InternalExtensionsWithConformances",
                    ],
                    [
                        "InternalExtensionsWithConstraints",
                    ],
                ]
                {
                    let parts:[SymbolGraphPart] = tests.load(
                        parts: culture.map { directory / "\($0).symbols.json" })
                    try compiler.compile(culture: parts[0].culture, parts: parts)
                }

                if  let tests:TestGroup = tests / "locations"
                {
                    for scalar:Compiler.Scalar
                        in compiler.scalars.load().local.lazy.map(\.scalars).joined()
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
    }
}
