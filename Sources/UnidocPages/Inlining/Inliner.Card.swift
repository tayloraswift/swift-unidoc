import HTML
import UnidocRecords

extension Inliner
{
    struct Card
    {
        let overview:Passage?

        let master:Record.Master
        let target:String?

        init(overview:Passage?, master:Record.Master, target:String?)
        {
            self.overview = overview
            self.master = master
            self.target = target
        }
    }
}
extension Inliner.Card:HyperTextOutputStreamable
{
    static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        switch self.master
        {
        case .article(let master):
            html[.li, { $0.class = "article" }]
            {
                $0[link: self.target] { $0[.h3] = master.headline.safe }
                $0 ?= self.overview
                $0[link: self.target] { $0.class = "read-more" } = "Read More"
            }

        case .culture(let master):
            html[.li, { $0.class = "module" }]
            {
                $0[link: self.target] = master.module.id
                $0 ?= self.overview
            }

        case .decl(let master):
            html[.li, { $0.class = "decl" }]
            {
                $0[link: self.target] = master.signature.abridged
                $0 ?= self.overview
            }

        case .file(_):
            //  unimplemented
            break
        }
    }
}
