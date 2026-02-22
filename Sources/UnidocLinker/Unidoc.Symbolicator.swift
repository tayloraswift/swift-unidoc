import Signatures
import SourceDiagnostics
import SymbolGraphs
import Symbols

extension Unidoc {
    @usableFromInline final class Symbolicator {
        @usableFromInline let demangler: Demangler?
        @usableFromInline let base: Symbol.FileBase?

        private let context: LinkerContext

        init(context: consuming LinkerContext, base: Symbol.FileBase?) {
            self.demangler = .init()
            self.base = base

            self.context = context
        }
    }
}
extension Unidoc.Symbolicator: DiagnosticSymbolicator {
    @usableFromInline subscript(article scalar: Unidoc.Scalar) -> Symbol.Article? {
        SymbolGraph.Plane.article.contains(scalar.citizen)
            ? self.context[scalar.package]?.articles.symbols[scalar.citizen]
            : nil
    }

    @usableFromInline subscript(decl scalar: Unidoc.Scalar) -> Symbol.Decl? {
        SymbolGraph.Plane.decl.contains(scalar.citizen)
            ? self.context[scalar.package]?.decls.symbols[scalar.citizen]
            : nil
    }

    @usableFromInline subscript(file scalar: Unidoc.Scalar) -> Symbol.File? {
        SymbolGraph.Plane.file.contains(scalar.citizen)
            ? self.context[scalar.package]?.files[scalar.citizen]
            : nil
    }
}
