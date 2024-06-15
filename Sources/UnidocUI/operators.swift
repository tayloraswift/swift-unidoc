import HTML
import LexicalPaths
import Signatures

func | (self:[GenericConstraint<Unidoc.Scalar?>],
    context:some Unidoc.VertexContext) -> Unidoc.WhereClause?
{
    self.isEmpty ? nil : .init(requirements: self, context: context)
}

func | (self:GenericConstraint<Unidoc.Scalar?>,
    context:some Unidoc.VertexContext) -> Unidoc.WhereClause.Requirement
{
    let whom:HTML.Link<UnqualifiedPath>

    switch self.whom
    {
    case .complex(let text):
        whom = .init(display: .init([], text), target: nil)

    case .nominal(let scalar):
        if  let scalar:Unidoc.Scalar,
            let link:HTML.Link<UnqualifiedPath> = context.link(decl: scalar)
        {
            whom = link
        }
        else if
            let scalar:Unidoc.Scalar
        {
            whom = .init(display: .init([], "(redacted, \(scalar))"), target: nil)
        }
        else
        {
            whom = .init(display: .init([], "(redacted)"), target: nil)
        }
    }

    return .init(parameter: self.noun, is: self.what, to: whom)
}
