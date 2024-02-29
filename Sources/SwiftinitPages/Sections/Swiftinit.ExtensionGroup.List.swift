import HTML
import Unidoc

extension Swiftinit.ExtensionGroup
{
    struct List
    {
        let context:IdentifiablePageContext<Swiftinit.Vertices>

        let heading:String
        let items:[Unidoc.Scalar]

        init(_ context:IdentifiablePageContext<Swiftinit.Vertices>,
            heading:String,
            items:[Unidoc.Scalar])
        {
            self.context = context
            self.heading = heading
            self.items = items
        }
    }
}
extension Swiftinit.ExtensionGroup.List:HTML.OutputStreamable
{
    static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        html[.h3] = self.heading
        html[.ul]
        {
            for scalar:Unidoc.Scalar in self.items
            {
                $0[.li] = self.context.card(scalar)
            }
        }
    }
}
