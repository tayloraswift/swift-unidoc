import HTML
import Unidoc

extension Unidoc
{
    struct SegregatedSection
    {
        private
        let list:SegregatedList
        private
        let type:SegregatedType
        private
        let id:String?

        private
        init(list:SegregatedList, type:SegregatedType, id:String?)
        {
            self.list = list
            self.type = type
            self.id = id
        }
    }
}
extension Unidoc.SegregatedSection
{
    init(list:Unidoc.SegregatedList, type:Unidoc.SegregatedType, in parent:String? = nil)
    {
        self.init(list: list, type: type, id: parent.map { "sg:\(type) in \($0)" })
    }
}
extension Unidoc.SegregatedSection
{
    var heading:Heading? { self.id.map { .init(type: self.type, id: $0) } }
}
extension Unidoc.SegregatedSection:HTML.OutputStreamable
{
    static
    func += (section:inout HTML.ContentEncoder, self:Self)
    {
        if  let heading:Heading = self.heading
        {
            section[.h3] = heading
        }
        else
        {
            section[.h3] = "\(self.type)"
        }

        section += self.list
    }
}
