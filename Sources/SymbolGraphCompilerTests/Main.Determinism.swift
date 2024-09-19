@_spi(testable) import SymbolGraphBuilder
import SymbolGraphCompiler
import Symbols
import System_
import Testing_

extension Main
{
    enum Determinism
    {
    }
}
extension Main.Determinism:TestBattery
{
    static
    func run(tests:TestGroup) throws
    {
        func loadSwift(from path:FilePath.Directory) throws -> SSGC.ModuleIndex?
        {
            let symbols:SSGC.SymbolDumps = try .collect(from: path)
            var symbolCache:SSGC.SymbolCache = .init(symbols: symbols)
            var typeChecker:SSGC.TypeChecker = .init()

            guard
            let symbols:SSGC.SymbolCulture = try symbolCache.load(
                module: "Swift",
                base: nil,
                as: .swift)
            else
            {
                return nil
            }

            try typeChecker.add(symbols: symbols)
            return try typeChecker.load(in: "Swift")
        }

        guard
        let a:SSGC.ModuleIndex = tests.expect(
            value: try loadSwift(from: "TestModules/SymbolGraphs")),
        let b:SSGC.ModuleIndex = tests.expect(
            value: try loadSwift(from: "TestModules/Determinism"))
        else
        {
            return
        }

        tests.expect(a.extensions ..? b.extensions)

        for (a, b):
            (
                (id:Symbol.Module, decls:[SSGC.Decl]),
                (id:Symbol.Module, decls:[SSGC.Decl])
            ) in zip(a.declarations, b.declarations)
        {
            tests.expect(a.id ==? b.id)
            tests.expect(a.decls ..? b.decls)
        }
    }
}
