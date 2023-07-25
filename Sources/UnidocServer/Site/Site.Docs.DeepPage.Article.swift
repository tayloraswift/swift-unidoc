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
        let inliner:Inliner
        private
        let path:QualifiedPath

        init(_ master:Record.Master.Article,
            extensions:[Record.Extension],
            inliner:Inliner)
        {
            self.master = master
            self.extensions = extensions
            self.inliner = inliner
            self.path = .init(splitting: self.master.stem)
        }
    }
}
extension Site.Docs.DeepPage.Article
{
    var zone:Record.Zone.Names
    {
        self.inliner.zones.principal.zone
    }

    var location:URI
    {
        .init(article: self.master, in: self.zone)
    }

    var title:String?
    {
        "\(self.zone.display ?? "\(self.zone.package)") Documentation"
    }
}
extension Site.Docs.DeepPage.Article:HyperTextOutputStreamable
{
    public static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        html[.section, { $0.class = "introduction" }]
        {
            $0[.div, { $0.class = "eyebrows" }]
            {
                $0[.span] { $0.class = "phylum" } = "Article"

                $0[link: self.inliner.uri(self.master.culture)] = self.path.namespace

                $0[.span, { $0.class = "culture" }]
                {
                    $0[.span] { $0.class = "version" } = self.zone.version
                }
            }

            $0 ?= self.master.overview.map(self.inliner.passage(_:))
        }
        html[.section] { $0.class = "details" } =
            self.master.details.map(self.inliner.passage(_:))
    }
}
