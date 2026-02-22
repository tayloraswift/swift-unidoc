import Sources
@_spi(testable) import SymbolGraphBuilder
import SymbolGraphCompiler
import SymbolGraphParts
import Symbols
import SystemIO
import Testing_

protocol CompilerTestBattery: TestBattery {
    static var inputs: [Symbol.Module] { get }

    static func run(tests: TestGroup, module: SSGC.ModuleIndex)
}
extension CompilerTestBattery {
    static func run(tests: TestGroup) throws {
        let symbols: SSGC.SymbolDumps = try .collect(from: "TestModules/SymbolGraphs")

        let module: SSGC.ModuleIndex? = (tests ! "Compilation").do {
            guard
            let subject: Symbol.Module = Self.inputs.last else {
                fatalError("No subject module!")
            }

            let base: Symbol.FileBase = "/swift/swift-unidoc/TestModules"

            var symbolCache: SSGC.SymbolCache = .init(symbols: symbols)
            var typeChecker: SSGC.TypeChecker = .init()
            for module: Symbol.Module in ["Swift", "_Concurrency"] {
                guard
                let symbols: SSGC.SymbolCulture = tests.expect(
                    value: try symbolCache.load(
                        module: module,
                        base: base,
                        as: .swift
                    )
                ) else {
                    continue
                }

                try typeChecker.add(symbols: symbols)
            }

            for module: Symbol.Module in Self.inputs {
                if  let symbols: SSGC.SymbolCulture = tests.expect(
                        value: try symbolCache.load(
                            module: module,
                            base: base,
                            as: .swift
                        )
                    ) {
                    try typeChecker.add(symbols: symbols)
                }
            }

            return try typeChecker.load(in: subject)
        }

        guard
        let module: SSGC.ModuleIndex else {
            return
        }

        Self.run(tests: tests, module: module)

        if  let tests: TestGroup = tests / "SourceLocations" {

            for (_, decls): (_, [SSGC.Decl]) in module.declarations {
                for decl: SSGC.Decl in decls {
                    if  let location: SourceLocation<Symbol.File> = tests.expect(
                            value: decl.location
                        ) {
                        tests.expect(true: location.file.path.starts(with: "Snippets/"))
                    }
                }
            }
        }
    }
}
