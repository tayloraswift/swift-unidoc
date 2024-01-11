import HTML
import LexicalPaths
import Signatures
import Unidoc

extension Swiftinit
{
    struct ConstraintsList
    {
        let context:any VertexPageContext

        private
        let constraints:[GenericConstraint<Unidoc.Scalar?>]

        init?(_ context:any VertexPageContext,
            constraints:[GenericConstraint<Unidoc.Scalar?>])
        {
            if  constraints.isEmpty
            {
                return nil
            }

            self.context = context
            self.constraints = constraints
        }
    }
}
extension Swiftinit.ConstraintsList:HTML.OutputStreamable
{
    static
    func += (code:inout HTML.ContentEncoder, self:Self)
    {
        var first:Bool = true
        for constraint:GenericConstraint<Unidoc.Scalar?> in self.constraints
        {
            if  first
            {
                first = false
                code[.span] { $0.highlight = .keyword } = "where"
                code += " "
            }
            else
            {
                code += ", "
            }

            code[.span] { $0.highlight = .typealias } = constraint.noun

            switch constraint.what
            {
            case    .conformer,
                    .subclass:  code += ":"
            case    .equal:     code += " == "
            }

            switch constraint.whom
            {
            case .complex(let text):
                code[.span] { $0.highlight = .type } = text

            case .nominal(let scalar):
                if  let scalar:Unidoc.Scalar,
                    let link:HTML.Link<UnqualifiedPath> = self.context.link(
                        decl: scalar)
                {
                    code += link
                }
                else if
                    let scalar:Unidoc.Scalar
                {
                    code += "(redacted, \(scalar))"
                }
                else
                {
                    code += "(redacted)"
                }
            }
        }
    }
}
