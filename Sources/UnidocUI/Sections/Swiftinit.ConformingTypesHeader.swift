import HTML
import Signatures
import Unidoc

extension Swiftinit
{
    struct ConformingTypesHeader
    {
        let context:Unidoc.PeripheralPageContext

        private
        let heading:ConformingTypesHeading

        init(_ context:Unidoc.PeripheralPageContext,
            heading:ConformingTypesHeading)
        {
            self.context = context
            self.heading = heading
        }
    }
}
extension Swiftinit.ConformingTypesHeader:HTML.OutputStreamable
{
    static
    func += (h2:inout HTML.ContentEncoder, self:Self)
    {
        let module:Unidoc.Scalar

        switch self.heading
        {
        case .citizens(in: let culture):    module = culture
        case .available(in: let culture):   module = culture
        case .extension(in: let culture):   module = culture
        }

        h2 += "Conforming types in "

        h2 ?= self.context.link(module: module)
    }
}
