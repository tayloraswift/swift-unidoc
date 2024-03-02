import Signatures
import SymbolGraphs
import Symbols
import SourceDiagnostics

extension Unidoc
{
    @usableFromInline final
    class Symbolicator
    {
        @usableFromInline
        let demangler:Demangler?
        @usableFromInline
        let root:Symbol.FileBase?

        private
        let context:Linker

        init(context:consuming Linker, root:Symbol.FileBase?)
        {
            self.demangler = .init()
            self.root = root

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
    func constraints(_ constraints:[GenericConstraint<Address?>]) -> String
    {
        constraints.map
        {
            switch $0
            {
            case    .where(let parameter, is: .equal, to: .nominal(let type?)):
                "\(parameter) == \(self[type])"

            case    .where(let parameter, is: .equal, to: .nominal(nil)):
                "\(parameter) == <unavailable>"

            case    .where(let parameter, is: .equal, to: .complex(let text)):
                "\(parameter) == \(text)"

            case    .where(let parameter, is: .subclass, to: .nominal(let type?)),
                    .where(let parameter, is: .conformer, to: .nominal(let type?)):
                "\(parameter):\(self[type])"

            case    .where(let parameter, is: .subclass, to: .nominal(nil)),
                    .where(let parameter, is: .conformer, to: .nominal(nil)):
                "\(parameter):<unavailable>"

            case    .where(let parameter, is: .subclass, to: .complex(let text)),
                    .where(let parameter, is: .conformer, to: .complex(let text)):
                "\(parameter):\(text)"
            }
        }.joined(separator: ", ")
    }
}
