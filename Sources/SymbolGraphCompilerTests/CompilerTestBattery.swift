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
    func run(tests:TestGroup, module:SSGC.ModuleIndex)
}
extension CompilerTestBattery
{
    static
    func run(tests:TestGroup) throws
    {
        let symbols:SSGC.SymbolDumps = try .collect(from: "TestModules/SymbolGraphs")

        let modules:[SSGC.ModuleIndex]? = (tests ! "Compilation").do
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
                if  let symbols:SSGC.SymbolCulture = tests.expect(value: try symbolCache.load(
                        module: $0,
                        base: base,
                        as: .swift))
                {
                    try typeChecker.add(symbols: symbols)
                }
                else
                {
                    return nil
                }

                return try typeChecker.load(in: $0)
            }
        }

        guard
        let modules:[SSGC.ModuleIndex]
        else
        {
            return
        }

        for module:SSGC.ModuleIndex in modules
        {
            Self.run(tests: tests, module: module)

            if  let tests:TestGroup = tests / "SourceLocations"
            {

                for (_, decls):(_, [SSGC.Decl]) in module.declarations
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
