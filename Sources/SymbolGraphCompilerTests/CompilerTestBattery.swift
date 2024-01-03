import Sources
import SymbolGraphCompiler
import SymbolGraphParts
import Symbols
import System
import Testing

protocol CompilerTestBattery:TestBattery
{
    static
    var inputs:[String] { get }

    static
    func run(tests:TestGroup,
        nominations:Compiler.Nominations,
        namespaces:[[Compiler.Namespace]],
        extensions:[Compiler.Extension])
}
extension CompilerTestBattery
{
    static
    func run(tests:TestGroup)
    {
        let directory:FilePath = "TestModules/SymbolGraphs"
        var compiler:Compiler = .init(root: "/swift/swift-unidoc/TestModules")

        let parts:[SymbolGraphPart] = Self.inputs.compactMap
        {
            let tests:TestGroup = (tests ! "LoadJSON") ! $0

            let path:FilePath = directory / "\($0).symbols.json"

            guard
            let id:FilePath.Component = tests.expect(value: path.lastComponent),
            let id:SymbolGraphPart.ID = .init(id.string)
            else
            {
                return nil
            }
            return tests.do
            {
                let part:SymbolGraphPart = try .init(
                    json: .init(utf8: try path.read([UInt8].self)),
                    id: id)

                tests.expect(part.metadata.version ==? .v(0, 6, 0))

                return part
            }
        }

        let compiled:(([[Compiler.Namespace]], Compiler.Nominations), [Compiler.Extension])? =
            (tests ! "Compilation").do
        {
            try compiler.compile(language: .swift, culture: parts[0].culture, parts: parts)

            return (compiler.declarations.load(), compiler.extensions.load())
        }

        guard
        case let ((namespaces, nominations), extensions)? = compiled
        else
        {
            return
        }

        if  let tests:TestGroup = tests / "SourceLocations"
        {
            for namespace:Compiler.Namespace in namespaces.joined()
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

        Self.run(tests: tests,
            nominations: nominations,
            namespaces: namespaces,
            extensions: extensions)
    }
}
