import HTML
import Signatures
import Symbols

extension Swiftinit
{
    struct ExtensionSection
    {
        private
        let context:IdentifiablePageContext<Swiftinit.Vertices>
        let heading:ExtensionHeading
        let constraints:[GenericConstraint<Unidoc.Scalar?>]
        let body:ExtensionBody

        private
        init(
            context:IdentifiablePageContext<Swiftinit.Vertices>,
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
extension Swiftinit.ExtensionSection
{
    init?(_ context:IdentifiablePageContext<Swiftinit.Vertices>,
        group:borrowing Unidoc.ExtensionGroup,
        decl:Phylum.DeclFlags,
        bias:Unidoc.Bias)
    {
        guard
        let body:Swiftinit.ExtensionBody = .init(context, group: group, decl: decl)
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
extension Swiftinit.ExtensionSection:HTML.OutputStreamable
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
        } = Swiftinit.ConstraintsList.init(self.context, constraints: self.constraints)

        section += self.body
    }
}
