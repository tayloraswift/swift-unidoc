import HTML
import Signatures
import Symbols

extension Unidoc
{
    struct ExtensionSection
    {
        private
        let context:Unidoc.InternalPageContext
        let heading:ExtensionHeading
        let constraints:[GenericConstraint<Unidoc.Scalar?>]
        let body:ExtensionBody

        private
        init(
            context:Unidoc.InternalPageContext,
            heading:ExtensionHeading,
            constraints:[GenericConstraint<Unidoc.Scalar?>],
            body:ExtensionBody)
        {
            self.context = context
            self.heading = heading
            self.constraints = constraints
            self.body = body
        }
    }
}
extension Unidoc.ExtensionSection
{
    init?(_ context:Unidoc.InternalPageContext,
        group:borrowing Unidoc.ExtensionGroup,
        decl:Phylum.DeclFlags,
        bias:Unidoc.Bias)
    {
        guard
        let body:Unidoc.ExtensionBody = .init(context, group: group, decl: decl)
        else
        {
            return nil
        }

        self.init(
            context: context,
            heading: .init(culture: group.culture, bias: bias),
            constraints: group.constraints,
            body: body)
    }
}
extension Unidoc.ExtensionSection:HTML.OutputStreamable
{
    static
    func += (section:inout HTML.ContentEncoder, self:Self)
    {
        section[.h2]
        {
            let module:Unidoc.Scalar

            switch self.heading
            {
            case .citizens(in: let culture):
                $0 += "Citizens in "
                module = culture

            case .available(in: let culture):
                $0 += "Available in "
                module = culture

            case .extension(in: let culture):
                $0 += "Extension in "
                module = culture
            }

            $0 ?= self.context.link(module: module)
        }

        section[.div, .code]
        {
            $0.class = "constraints"
        } = Unidoc.ConstraintsList.init(self.context, constraints: self.constraints)

        section += self.body
    }
}
