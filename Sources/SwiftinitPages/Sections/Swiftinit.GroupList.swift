import HTML
import Unidoc

extension Swiftinit
{
    struct GroupList
    {
        let context:IdentifiablePageContext<Swiftinit.Vertices>

        let heading:String?
        let scalars:[Unidoc.Scalar]

        init(_ context:IdentifiablePageContext<Swiftinit.Vertices>,
            heading:String?,
            scalars:[Unidoc.Scalar])
        {
            self.context = context
            self.heading = heading
            self.scalars = scalars
        }
    }
}
extension Swiftinit.GroupList:HTML.OutputStreamable
{
    static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        if  let heading:String = self.heading
        {
            html[.h3] = heading
        }
        html[.ul]
        {
            for scalar:Unidoc.Scalar in self.scalars
            {
                $0 ?= self.context.card(scalar)
            }
        }
    }
}
