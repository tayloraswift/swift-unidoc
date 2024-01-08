import HTML
import Unidoc

extension Swiftinit.DenseList
{
    struct Card
    {
        let link:HTML.Link<String>
        let constraints:Swiftinit.ConstraintsList?

        init(link:HTML.Link<String>, constraints:Swiftinit.ConstraintsList?)
        {
            self.link = link
            self.constraints = constraints
        }
    }
}
extension Swiftinit.DenseList.Card:HTML.OutputStreamable
{
    static
    func += (li:inout HTML.ContentEncoder, self:Self)
    {
        li[.p] { $0[.code] = self.link }

        guard
        let constraints:Swiftinit.ConstraintsList = self.constraints
        else
        {
            return
        }

        li[.p] { $0[.code] { $0.class = "constraints" } = constraints }
    }
}
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
extension Swiftinit.DenseList:RandomAccessCollection
{
    var startIndex:Int { self.members.startIndex }
    var endIndex:Int { self.members.endIndex }

    subscript(i:Int) -> Card?
    {
        let type:Unidoc.ConformingType = self.members[i]

        guard
        let link:HTML.Link<String> = self.context.link(decl: type.id)
        else
        {
            return nil
        }

        return .init(link: link, constraints: self.context.constraints(type.constraints))
    }
}
extension Swiftinit.DenseList:HTML.OutputStreamable
{
    static
    func += (ul:inout HTML.ContentEncoder, self:Self)
    {
        for case let card? in self
        {
            ul[.li] = card
        }
    }
}
