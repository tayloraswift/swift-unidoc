import HTML
import LexicalPaths
import Signatures

func | (self:[GenericConstraint<Unidoc.Scalar>],
    context:some Unidoc.VertexContext) -> Unidoc.WhereClause?
{
    self.isEmpty ? nil : .init(requirements: self, context: context)
}

func | (self:GenericConstraint<Unidoc.Scalar>,
    context:some Unidoc.VertexContext) -> Unidoc.WhereClause.Requirement
{
    let whom:HTML.Link<UnqualifiedPath>

    if  self.whom.spelling.isEmpty
    {
        //  Backwards compatibility
        if  let scalar:Unidoc.Scalar = self.whom.nominal,
            let link:HTML.Link<UnqualifiedPath> = context.link(decl: scalar)
        {
            whom = link
        }
        else if
            let scalar:Unidoc.Scalar = self.whom.nominal
        {
            whom = .init(display: .init([], "(redacted, \(scalar))"), target: nil)
        }
        else
        {
            whom = .init(display: .init([], "(redacted)"), target: nil)
        }
    }
    else
    {
        whom = .init(
            display: .init([], self.whom.spelling),
            target: self.whom.nominal.map { context[decl: $0]?.target?.url } ?? nil)
    }

    return .init(parameter: self.noun, is: self.what, to: whom)
}
