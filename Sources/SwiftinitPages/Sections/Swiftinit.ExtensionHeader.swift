import HTML
import Signatures
import Unidoc

extension Swiftinit
{
    struct ExtensionHeader
    {
        let context:IdentifiablePageContext<Swiftinit.Vertices>

        private
        let heading:ExtensionHeading

        private
        let constraints:[GenericConstraint<Unidoc.Scalar?>]

        init(_ context:IdentifiablePageContext<Swiftinit.Vertices>,
            heading:ExtensionHeading,
            where constraints:[GenericConstraint<Unidoc.Scalar?>])
        {
            self.context = context
            self.heading = heading
            self.constraints = constraints
        }
    }
}
extension Swiftinit.ExtensionHeader:HTML.OutputStreamable
{
    static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        html[.h2]
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

        html[.code] { $0.class = "constraints" } = self.context.constraints(self.constraints)
    }
}
