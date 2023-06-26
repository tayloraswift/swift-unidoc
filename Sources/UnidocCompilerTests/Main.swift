import Sources
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
                    for namespace:Compiler.Namespace
                        in compiler.declarations.load().namespaces.joined()
                    {
                        for decl:Compiler.Decl in namespace.decls
                        {
                            if  let location:SourceLocation<Symbol.File> = tests.expect(
                                    value: decl.location)
                            {
                                tests.expect(true: location.file.path.starts(with: "Snippets/"))
                            }
                        }
                    }
                }
            }
        }
    }
}
