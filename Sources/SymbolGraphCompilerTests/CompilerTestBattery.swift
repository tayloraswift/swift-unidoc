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
        nominations:SSGC.Nominations,
        namespaces:[[SSGC.Namespace]],
        extensions:[SSGC.Extension])
}
extension CompilerTestBattery
{
    static
    func run(tests:TestGroup)
    {
        let directory:FilePath = "TestModules/SymbolGraphs"
        var checker:SSGC.TypeChecker = .init(root: "/swift/swift-unidoc/TestModules")

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

        let compiled:(([[SSGC.Namespace]], SSGC.Nominations), [SSGC.Extension])? =
            (tests ! "Compilation").do
        {
            try checker.compile(language: .swift, culture: parts[0].culture, parts: parts)

            return (checker.declarations.load(), checker.extensions.load())
        }

        guard
        case let ((namespaces, nominations), extensions)? = compiled
        else
        {
            return
        }

        if  let tests:TestGroup = tests / "SourceLocations"
        {
            for namespace:SSGC.Namespace in namespaces.joined()
            {
                for decl:SSGC.Decl in namespace.decls
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
