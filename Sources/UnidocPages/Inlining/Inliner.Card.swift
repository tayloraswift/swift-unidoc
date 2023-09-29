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

        let master:Volume.Vertex
        let target:String?

        init(overview:Passage?, master:Volume.Vertex, target:String?)
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
                //  There is no better way to compute the monospace width of markdown than
                //  rendering it to plain text and performing grapheme breaking.
                let width:Int = "\(master.signature.abridged.bytecode.safe)".count

                //  The em width of a single glyph of the IBM Plex Mono font is 600 / 1000,
                //  or 0.6. We consider a signature to be “long” if it occupies more than
                //  48 em units. Therefore the threshold is 48 / 0.6 = 80 characters.
                $0[.code, { $0.class = width > 80 ? "multiline" : nil }]
                {
                    $0[link: self.target]
                    {
                        $0.class = master.signature.availability.isGenerallyRecommended ?
                            nil : "discouraged"
                    } = master.signature.abridged
                }

                $0 ?= self.overview
            }

        case .file(_), .global:
            //  unimplemented
            break
        }
    }
}
