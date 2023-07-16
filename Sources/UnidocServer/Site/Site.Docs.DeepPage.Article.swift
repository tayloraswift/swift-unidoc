import HTML
import MarkdownRendering
import UnidocRecords
import URI

extension Site.Docs.DeepPage
{
    struct Article
    {
        let master:Record.Master.Article
        let extensions:[Record.Extension]

        private
        let renderer:Renderer

        init(_ master:Record.Master.Article,
            extensions:[Record.Extension],
            renderer:Renderer)
        {
            self.master = master
            self.extensions = extensions
            self.renderer = renderer
        }
    }
}
extension Site.Docs.DeepPage.Article
{
    var zone:Record.Zone.Names
    {
        self.renderer.zones.principal.zone
    }

    var location:URI
    {
        .init(article: self.master, in: self.zone)
    }
}
extension Site.Docs.DeepPage.Article:HyperTextOutputStreamable
{
    public static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        html[.head]

        html[.body]
        {
            $0[.section, { $0[.class] = "introduction" }]
            {
                $0[.div, { $0[.class] = "eyebrows" }]
                {
                    $0[.span, { $0[.class] = "phylum" }] = "Article"
                }


                $0 ?= self.renderer.prose(self.master.overview)
                $0 ?= self.renderer.prose(self.master.details)
            }
        }
    }
}
