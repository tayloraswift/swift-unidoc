import HTML
import Unidoc

extension Swiftinit
{
    struct DenseList
    {
        let context:IdentifiablePageContext<Unidoc.Scalar>

        let members:[Unidoc.ConformingType]

        init(_ context:IdentifiablePageContext<Unidoc.Scalar>, members:[Unidoc.ConformingType])
        {
            self.context = context
            self.members = members
        }
    }
}
extension Swiftinit.DenseList:HTML.OutputStreamable
{
    static
    func += (ul:inout HTML.ContentEncoder, self:Self)
    {
        for type:Unidoc.ConformingType in self.members
        {
            ul[.li]
            {
                $0[.p] = self.context.link(decl: type.id)
                $0[.p]
                {
                    $0 += "Available"
                    $0[.code]
                    {
                        $0.class = "constraints"
                    } = self.context.constraints(type.constraints)
                }
            }
        }
    }
}
