import HTML
import Signatures
import Unidoc

struct ConstraintsList
{
    let context:IdentifiablePageContext<Unidoc.Scalar>

    private
    let constraints:[GenericConstraint<Unidoc.Scalar?>]

    init?(_ context:IdentifiablePageContext<Unidoc.Scalar>,
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
extension ConstraintsList:HyperTextOutputStreamable
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

            code[.span, { $0.highlight = .type }]
            {
                switch constraint.whom
                {
                case .complex(let text):
                    $0 += text

                case .nominal(let scalar):
                    if  let scalar:Unidoc.Scalar,
                        let link:HTML.Link<String> = self.context.link(
                            decl: scalar)
                    {
                        $0 += link
                    }
                    else if
                        let scalar:Unidoc.Scalar
                    {
                        $0 += "(redacted, \(scalar))"
                    }
                    else
                    {
                        $0 += "(redacted)"
                    }
                }
            }
        }
    }
}
