import Sources
@_spi(testable) import SymbolGraphBuilder
import Symbols
import SystemIO
import Testing

extension SSGC.ModuleIndex {
    static func load(
        module: Symbol.Module = "Swift",
        from path: FilePath.Directory
    ) throws -> Self? {
        let symbols: SSGC.SymbolDumps = try .collect(from: path)
        var symbolCache: SSGC.SymbolCache = .init(symbols: symbols)
        var typeChecker: SSGC.TypeChecker = .init()

        guard
        let symbols: SSGC.SymbolCulture = try symbolCache.load(
            module: module,
            base: nil,
            as: .swift
        ) else {
            return nil
        }

        try typeChecker.add(symbols: symbols)
        return try typeChecker.load(in: "Swift")
    }

    static func load(inputs: [Symbol.Module]) throws -> Self {
        let symbols: SSGC.SymbolDumps = try .collect(from: "TestModules/SymbolGraphs")
        let subject: Symbol.Module = try #require(inputs.last, "No subject module!")

        let base: Symbol.FileBase = "/swift/unidoc/TestModules"

        var symbolCache: SSGC.SymbolCache = .init(symbols: symbols)
        var typeChecker: SSGC.TypeChecker = .init()
        for module: Symbol.Module in ["Swift", "_Concurrency"] {
            let symbols: SSGC.SymbolCulture = try #require(
                try symbolCache.load(module: module, base: base, as: .swift)
            )
            try typeChecker.add(symbols: symbols)
        }

        for module: Symbol.Module in inputs {
            let symbols: SSGC.SymbolCulture = try #require(
                try symbolCache.load(module: module, base: base, as: .swift)
            )
            try typeChecker.add(symbols: symbols)
        }

        return try typeChecker.load(in: subject)
    }

    func testSourceLocations(in test: String = #function) throws {
        for (_, decls): (_, [SSGC.Decl]) in self.declarations {
            for decl: SSGC.Decl in decls {
                #expect(true == decl.location?.file.path.starts(with: "Snippets/"))
            }
        }
    }
}
