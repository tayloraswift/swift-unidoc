import HTML
import LexicalPaths
import Signatures
import Symbols

extension Swiftinit.DenseList
{
    struct Card
    {
        let target:String
        let decl:Unidoc.DeclVertex
        let path:UnqualifiedPath
        let constraints:Swiftinit.ConstraintsList?

        private
        init(target:String,
            decl:Unidoc.DeclVertex,
            path:UnqualifiedPath,
            constraints:Swiftinit.ConstraintsList?)
        {
            self.target = target
            self.decl = decl
            self.path = path
            self.constraints = constraints
        }
    }
}
extension Swiftinit.DenseList.Card
{
    init?(_ type:Unidoc.Scalar,
        constraints:[GenericConstraint<Unidoc.Scalar?>] = [],
        with context:some Swiftinit.VertexPageContext)
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
extension Swiftinit.DenseList.Card:HTML.OutputStreamableAnchor
{
    var id:String { "\(self.decl.symbol)" }
}
extension Swiftinit.DenseList.Card:HTML.OutputStreamable
{
    static
    func += (li:inout HTML.ContentEncoder, self:Self)
    {
        li[.a] { $0.href = "#\(self.id)" }
        li[.code, { $0.class = "decl" }] { $0[.a] { $0.href = self.target } = self.path }
        li[.div, .code] { $0.class = "constraints" } = self.constraints
    }
}
