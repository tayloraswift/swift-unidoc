import SourceDiagnostics
import SymbolGraphs
import Symbols

extension SSGC {
    @_spi(testable) public struct Symbolicator: Sendable {
        public let demangler: Demangler?
        public let base: Symbol.FileBase?

        private let graph: SymbolGraph

        init(graph: SymbolGraph, base: Symbol.FileBase?) {
            self.demangler = .init()
            self.base = base

            self.graph = graph
        }
    }
}
@_spi(testable) extension SSGC.Symbolicator: DiagnosticSymbolicator {
    public subscript(article scalar: Int32) -> Symbol.Article? {
        SymbolGraph.Plane.article.contains(scalar)
            ? self.graph.articles.symbols[scalar]
            : nil
    }

    public subscript(decl scalar: Int32) -> Symbol.Decl? {
        SymbolGraph.Plane.decl.contains(scalar)
            ? self.graph.decls.symbols[scalar]
            : nil
    }

    public subscript(file scalar: Int32) -> Symbol.File? {
        SymbolGraph.Plane.file.contains(scalar)
            ? self.graph.files[scalar]
            : nil
    }
}
