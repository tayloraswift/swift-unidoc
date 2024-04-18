import HTML
import Unidoc

extension Unidoc
{
    struct DenseList
    {
        let context:Unidoc.PeripheralPageContext

        let members:([Unidoc.Scalar], [Unidoc.ConformingType])

        init(_ context:Unidoc.PeripheralPageContext,
            members:([Unidoc.Scalar], [Unidoc.ConformingType]))
        {
            self.context = context
            self.members = members
        }
    }
}
extension Unidoc.DenseList:Sequence
{
    func makeIterator() -> Iterator
    {
        .init(context: self.context, members: self.members)
    }
}
extension Unidoc.DenseList:HTML.OutputStreamable
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
