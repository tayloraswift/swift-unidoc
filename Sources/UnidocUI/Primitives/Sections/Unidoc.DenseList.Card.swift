import HTML
import LexicalPaths
import Signatures
import Symbols

extension Unidoc.DenseList
{
    struct Card
    {
        let target:Unidoc.LinkTarget
        let decl:Unidoc.DeclVertex
        let path:UnqualifiedPath
        let constraints:Unidoc.ConstraintsList?

        private
        init(target:Unidoc.LinkTarget,
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
        let reference:Unidoc.LinkReference<Unidoc.DeclVertex> = context[decl: type],
        let target:Unidoc.LinkTarget = reference.target,
        let path:UnqualifiedPath = .init(splitting: reference.vertex.stem)
        else
        {
            return nil
        }

        self.init(target: target,
            decl: reference.vertex,
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
        li[.code, { $0.class = "decl" }] { $0[.a] { $0.link = self.target } = self.path }
        li[.div, .code] { $0.class = "constraints" } = self.constraints
    }
}
