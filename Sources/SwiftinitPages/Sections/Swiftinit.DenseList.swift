import HTML
import Unidoc

extension Swiftinit
{
    struct DenseList
    {
        let context:IdentifiablePageContext<Swiftinit.SecondaryOnly>

        let members:([Unidoc.Scalar], [Unidoc.ConformingType])

        init(_ context:IdentifiablePageContext<Swiftinit.SecondaryOnly>,
            members:([Unidoc.Scalar], [Unidoc.ConformingType]))
        {
            self.context = context
            self.members = members
        }
    }
}
extension Swiftinit.DenseList:Sequence
{
    func makeIterator() -> Iterator
    {
        .init(context: self.context, members: self.members)
    }
}
extension Swiftinit.DenseList:HTML.OutputStreamable
{
    static
    func += (ul:inout HTML.ContentEncoder, self:Self)
    {
        for card:Card in self
        {
            ul[.li] = card
        }
    }
}
