import HTML
import LexicalPaths

extension Swiftinit.DenseList
{
    struct Card
    {
        let link:HTML.Link<UnqualifiedPath>
        let constraints:Swiftinit.ConstraintsList?

        init(link:HTML.Link<UnqualifiedPath>, constraints:Swiftinit.ConstraintsList?)
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
