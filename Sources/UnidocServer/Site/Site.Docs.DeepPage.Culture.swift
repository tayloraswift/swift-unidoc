import HTML
import MarkdownRendering
import ModuleGraphs
import UnidocRecords
import URI

extension Site.Docs.DeepPage
{
    struct Culture
    {
        let master:Record.Master.Culture
        let extensions:[Record.Extension]

        private
        let inliner:Inliner

        init(_ master:Record.Master.Culture,
            extensions:[Record.Extension],
            inliner:Inliner)
        {
            self.master = master
            self.extensions = extensions
            self.inliner = inliner
        }
    }
}
extension Site.Docs.DeepPage.Culture
{
    var zone:Record.Zone.Names
    {
        self.inliner.zones.principal.zone
    }

    var location:URI
    {
        .init(culture: self.master, in: self.zone)
    }
}
extension Site.Docs.DeepPage.Culture:HyperTextOutputStreamable
{
    public static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        html[.head]
        {
            //  TODO: this should include the package name
            $0[.title] = self.master.module.name
        }
        html[.body]
        {
            $0[.section, { $0.class = "introduction" }]
            {
                $0[.div, { $0.class = "eyebrows" }]
                {
                    $0[.span, { $0.class = "phylum" }] = "Module"
                }

                $0[.h1] = self.master.module.name

                $0 ?= self.master.overview.map(self.inliner.prose(_:))
            }

            $0[.section, { $0.class = "declaration" }]
            {
                $0[.pre]
                {
                    $0[.code]
                    {
                        $0[.span] { $0.highlight = .keyword } = "import"
                        $0 += " "
                        $0[.span] { $0.highlight = .identifier } = self.master.module.id
                    }
                }
            }

            $0[.section] { $0.class = "details" } =
                self.master.details.map(self.inliner.prose(_:))
        }
    }
}
