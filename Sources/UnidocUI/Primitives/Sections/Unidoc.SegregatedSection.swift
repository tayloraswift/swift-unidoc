import HTML
import Unidoc

extension Unidoc
{
    struct SegregatedSection
    {
        let heading:String
        let items:SegregatedList

        init(heading:String, items:SegregatedList)
        {
            self.heading = heading
            self.items = items
        }
    }
}
extension Unidoc.SegregatedSection:HTML.OutputStreamable
{
    static
    func += (section:inout HTML.ContentEncoder, self:Self)
    {
        section[.h3] = self.heading
        section += self.items
    }
}
