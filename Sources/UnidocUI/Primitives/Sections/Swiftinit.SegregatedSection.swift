import HTML
import Unidoc

extension Swiftinit
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
extension Swiftinit.SegregatedSection:HTML.OutputStreamable
{
    static
    func += (section:inout HTML.ContentEncoder, self:Self)
    {
        section[.h3] = self.heading
        section += self.items
    }
}
