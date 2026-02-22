import MarkdownABI
import MarkdownAST
import MarkdownPluginSwift
import Snippets
import SourceDiagnostics
import SymbolGraphCompiler
import SymbolGraphLinker
import SymbolGraphParts
import SymbolGraphs
import Symbols
import SystemIO

extension SSGC {
    protocol DocumentationSources {
        var modules: ModuleGraph { get }
        var symbols: [FilePath.Directory] { get }
        var prefix: Symbol.FileBase? { get }

        /// Returns all constituents of the given module (including transitive dependencies),
        /// sorted in topological dependency order. The list ends with the given module.
        // func constituents(of culture:__owned ModuleLayout) throws -> [ModuleLayout]

        func indexStore(
            for swift: SSGC.Toolchain
        ) throws -> (any Markdown.SwiftLanguage.IndexStore)?
    }
}
extension SSGC.DocumentationSources {
    func link(
        definitions: [String: Void],
        logger: SSGC.Logger,
        with swift: SSGC.Toolchain
    ) throws -> SymbolGraph {
        let plans: [(SSGC.ModuleLayout, [SSGC.ModuleLayout])] = self.modules.plans
        let snippets: [SSGC.LazyFile] = self.modules.snippets
        let prefix: Symbol.FileBase? = self.prefix

        let moduleIndexes: [SSGC.ModuleIndex]

        var profiler: SSGC.DocumentationBuildProfiler = .init()
        do {
            var symbolCache: SSGC.SymbolCache = .init(symbols: try .collect(from: self.symbols))

            moduleIndexes = try plans.map {
                let constituents: [SSGC.ModuleLayout] = $1.filter(\.module.type.hasSymbols)
                let id: Symbol.Module = $0.id

                let symbols: (
                    missing: [SSGC.ModuleLayout],
                    loaded: [SSGC.SymbolCulture]
                ) = try profiler.measure(\.loadingSymbols) {
                    let selection: Set<Symbol.Module> = constituents.reduce(into: []) {
                        $0.insert($1.id)
                    }

                    return try constituents.reduce(into: ([], [])) {
                        if  let module: SSGC.SymbolCulture = try symbolCache.load(
                                module: $1.id,
                                filter: selection,
                                base: prefix,
                                as: $1.language ?? .swift
                            ) {
                            $0.loaded.append(module)
                        } else {
                            $0.missing.append($1)
                        }
                    }
                }

                print("Compiling documentation for \(id)...")

                if !symbols.missing.isEmpty {
                    print("WARNING: \(symbols.missing.count) modules failed to dump symbols")
                    for module: SSGC.ModuleLayout in symbols.missing {
                        print("  - \(module.id) (\(module.language ?? .swift))")
                    }
                }

                let compiler: SSGC.TypeChecker = try profiler.measure(\.compiling) {
                    try symbols.loaded.reduce(into: .init()) {
                        try $0.add(symbols: $1)
                    }
                }

                var module: SSGC.ModuleIndex = try compiler.load(in: id)

                module.resources = $0.resources
                module.markdown = $0.markdown
                module.language = $0.language

                return module
            }

            print(
                """
                Compiled documentation!
                    time loading symbols    : \(profiler.loadingSymbols)
                    time compiling          : \(profiler.compiling)
                cultures        : \(plans.count)
                namespaces      : \(moduleIndexes.reduce(0) { $0 + $1.declarations.count })
                declarations    : \(moduleIndexes.reduce(0) {
                        $0 + $1.declarations.reduce(0) { $0 + $1.decls.count }
                    })
                re-exports      : \(moduleIndexes.reduce(0) { $0 + $1.reexports.count })
                extensions      : \(moduleIndexes.reduce(0) { $0 + $1.extensions.count })
                """
            )
        } catch let error {
            throw SSGC.DocumentationBuildError.loading(error)
        }

        do {
            let index: (any Markdown.SwiftLanguage.IndexStore)?
            do {
                index = try self.indexStore(for: swift)
            } catch let error {
                print("""
                    Couldn’t load IndexStoreDB library, advanced syntax highlighting will be \
                    disabled! (\(error))
                    """)
                index = nil
            }

            let graph: SymbolGraph = try profiler.measure(\.linking) {
                try .link(
                    projectRoot: prefix,
                    definitions: definitions,
                    plugins: [.swift(index: index)],
                    modules: plans.map(\.0.module),
                    indexes: moduleIndexes,
                    snippets: snippets,
                    logger: logger
                )
            }

            for resource: SSGC.LazyFile in plans.lazy.map(\.0.resources).joined() {
                profiler.loadingSources += resource.loadingTime
                profiler.linking -= resource.loadingTime
            }
            for markdown: SSGC.LazyFile in plans.lazy.map(\.0.markdown).joined() {
                profiler.loadingSources += markdown.loadingTime
                profiler.linking -= markdown.loadingTime
            }
            for snippet: SSGC.LazyFile in snippets {
                profiler.loadingSources += snippet.loadingTime
                profiler.linking -= snippet.loadingTime
            }

            print("""
                Linked documentation!
                    time loading sources    : \(profiler.loadingSources)
                    time linking            : \(profiler.linking)
                symbols             : \(graph.decls.symbols.count)
                redirects           : \
                \(graph.cultures.reduce(0) { $0 + $1.reexports.unhashed.count })
                redirects (hashed)  : \
                \(graph.cultures.reduce(0) { $0 + $1.reexports.hashed.count })
                """)

            return graph
        } catch let error {
            throw SSGC.DocumentationBuildError.linking(error)
        }
    }
}
