import HTML
import UnidocRecords

extension Inliner.Card
{
    enum Color
    {
    }
}
extension Inliner
{
    struct Card
    {
        let overview:Passage?

        let master:Volume.Master
        let target:String?

        init(overview:Passage?, master:Volume.Master, target:String?)
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
                let style:String? = master.signature.availability.isGenerallyRecommended ?
                    nil : "not-recommended"

                $0[link: self.target] { $0.class = style } = master.signature.abridged
                $0 ?= self.overview
            }

        case .file(_), .meta(_):
            //  unimplemented
            break
        }
    }
}
