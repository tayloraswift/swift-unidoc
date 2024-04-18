import HTML
import LexicalPaths
import Signatures
import Symbols

extension Unidoc.DenseList
{
    struct Card
    {
        let target:String
        let decl:Unidoc.DeclVertex
        let path:UnqualifiedPath
        let constraints:Unidoc.ConstraintsList?

        private
        init(target:String,
            decl:Unidoc.DeclVertex,
            path:UnqualifiedPath,
            constraints:Unidoc.ConstraintsList?)
        {
            self.target = target
            self.decl = decl
            self.path = path
            self.constraints = constraints
        }
    }
}
extension Unidoc.DenseList.Card
{
    init?(_ type:Unidoc.Scalar,
        constraints:[GenericConstraint<Unidoc.Scalar?>] = [],
        with context:some Unidoc.VertexContext)
    {
        guard
        case (let decl, let url?)? = context[decl: type],
        let path:UnqualifiedPath = .init(splitting: decl.stem)
        else
        {
            return nil
        }

        self.init(target: url,
            decl: decl,
            path: path,
            constraints: .init(context, constraints: constraints))
    }
}
extension Unidoc.DenseList.Card:HTML.OutputStreamableAnchor
{
    var id:String { "\(self.decl.symbol)" }
}
extension Unidoc.DenseList.Card:HTML.OutputStreamable
{
    static
    func += (li:inout HTML.ContentEncoder, self:Self)
    {
        li[.a] { $0.href = "#\(self.id)" }
        li[.code, { $0.class = "decl" }] { $0[.a] { $0.href = self.target } = self.path }
        li[.div, .code] { $0.class = "constraints" } = self.constraints
    }
}
