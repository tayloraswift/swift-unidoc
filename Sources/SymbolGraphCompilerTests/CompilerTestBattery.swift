import Sources
@_spi(testable) import SymbolGraphBuilder
import SymbolGraphCompiler
import SymbolGraphParts
import Symbols
import System
import Testing_

protocol CompilerTestBattery:TestBattery
{
    static
    var inputs:[Symbol.Module] { get }

    static
    func run(tests:TestGroup, declarations:SSGC.Declarations, extensions:SSGC.Extensions)
}
extension CompilerTestBattery
{
    static
    func run(tests:TestGroup) throws
    {
        let symbols:SSGC.SymbolDumps = try .collect(from: "TestModules/SymbolGraphs")

        let compiled:[(SSGC.Declarations, SSGC.Extensions)]? = (tests ! "Compilation").do
        {
            let base:Symbol.FileBase = "/swift/swift-unidoc/TestModules"

            var symbolCache:SSGC.SymbolCache = .init(symbols: symbols)
            var typeChecker:SSGC.TypeChecker = .init()
            for module:Symbol.Module in ["Swift", "_Concurrency"]
            {
                guard
                let symbols:SSGC.SymbolCulture = tests.expect(value: try symbolCache.load(
                    module: module,
                    base: base,
                    as: .swift))
                else
                {
                    continue
                }

                try typeChecker.add(symbols: symbols)
            }

            return try Self.inputs.compactMap
            {
                guard
                let symbols:SSGC.SymbolCulture = tests.expect(value: try symbolCache.load(
                    module: $0,
                    base: base,
                    as: .swift))
                else
                {
                    return nil
                }

                try typeChecker.add(symbols: symbols)
                return (
                    typeChecker.declarations(in: $0, language: .swift),
                    try typeChecker.extensions(in: $0)
                )
            }
        }

        guard
        let compiled:[(SSGC.Declarations, SSGC.Extensions)]
        else
        {
            return
        }

        for (declarations, extensions):(SSGC.Declarations, SSGC.Extensions) in compiled
        {
            Self.run(tests: tests, declarations: declarations, extensions: extensions)

            if  let tests:TestGroup = tests / "SourceLocations"
            {

                for (_, decls):(_, [SSGC.Decl]) in declarations.namespaces
                {
                    for decl:SSGC.Decl in decls
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
