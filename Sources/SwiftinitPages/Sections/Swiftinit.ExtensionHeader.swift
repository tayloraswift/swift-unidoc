import HTML
import Unidoc

extension Swiftinit
{
    struct ExtensionHeader
    {
        let context:IdentifiablePageContext<Swiftinit.Vertices>

        private
        let heading:ExtensionHeading

        init(_ context:IdentifiablePageContext<Swiftinit.Vertices>,
            heading:ExtensionHeading)
        {
            self.context = context
            self.heading = heading
        }
    }
}
extension Swiftinit.ExtensionHeader:HTML.OutputStreamable
{
    static
    func += (h2:inout HTML.ContentEncoder, self:Self)
    {
        let module:Unidoc.Scalar

        switch self.heading
        {
        case .citizens(in: let culture):
            h2 += "Citizens in "
            module = culture

        case .available(in: let culture):
            h2 += "Available in "
            module = culture

        case .extension(in: let culture):
            h2 += "Extension in "
            module = culture
        }

        h2 ?= self.context.link(module: module)
    }
}
