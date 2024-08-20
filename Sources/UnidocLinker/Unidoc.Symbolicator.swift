import Signatures
import SourceDiagnostics
import SymbolGraphs
import Symbols

extension Unidoc
{
    @usableFromInline final
    class Symbolicator
    {
        @usableFromInline
        let demangler:Demangler?
        @usableFromInline
        let base:Symbol.FileBase?

        private
        let context:Linker

        init(context:consuming Linker, base:Symbol.FileBase?)
        {
            self.demangler = .init()
            self.base = base

            self.context = context
        }
    }
}
extension Unidoc.Symbolicator:DiagnosticSymbolicator
{
    @usableFromInline
    subscript(article scalar:Unidoc.Scalar) -> Symbol.Article?
    {
        SymbolGraph.Plane.article.contains(scalar.citizen)
            ? self.context[scalar.package]?.articles.symbols[scalar.citizen]
            : nil
    }

    @usableFromInline
    subscript(decl scalar:Unidoc.Scalar) -> Symbol.Decl?
    {
        SymbolGraph.Plane.decl.contains(scalar.citizen)
            ? self.context[scalar.package]?.decls.symbols[scalar.citizen]
            : nil
    }

    @usableFromInline
    subscript(file scalar:Unidoc.Scalar) -> Symbol.File?
    {
        SymbolGraph.Plane.file.contains(scalar.citizen)
            ? self.context[scalar.package]?.files[scalar.citizen]
            : nil
    }
}
extension Unidoc.Symbolicator
{
    private
    func spell(_ type:GenericType<Address>) -> String
    {
        guard type.spelling.isEmpty
        else
        {
            return type.spelling
        }

        if  let id:Address = type.nominal
        {
            return self[id]
        }
        else
        {
            return "<unavailable>"
        }
    }

    func constraints(_ constraints:[GenericConstraint<Address>]) -> String
    {
        constraints.map
        {
            switch $0
            {
            case .where(let parameter, is: .equal, to: let type):
                return "\(parameter) == \(self.spell(type))"

            case .where(let parameter, is: .subclass, to: let type):
                fallthrough

            case .where(let parameter, is: .conformer, to: let type):
                return "\(parameter):\(self.spell(type))"
            }
        }.joined(separator: ", ")
    }
}
