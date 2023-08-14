import HTML
import MarkdownRendering
import UnidocRecords
import Unidoc
import URI

extension Site.Docs
{
    struct Article
    {
        private
        let inliner:Inliner

        private
        let master:Record.Master.Article
        private
        let groups:[Record.Group]
        private
        let types:[Record.TypeTree.Row]


        init(_ inliner:Inliner,
            master:Record.Master.Article,
            groups:[Record.Group],
            types:[Record.TypeTree.Row])
        {
            self.inliner = inliner
            self.master = master
            self.groups = groups
            self.types = types
        }
    }
}
extension Site.Docs.Article
{
    private
    var zone:Record.Zone { self.inliner.zones.principal }

    private
    var stem:Record.Stem { self.master.stem }
}
extension Site.Docs.Article:FixedPage
{
    var location:URI { Site.Docs[self.zone, self.master.shoot] }

    var title:String
    {
        "\(self.zone.display ?? "\(self.zone.package)") Documentation"
    }

    var sidebar:Inliner.TypeTree?
    {
        .init(self.inliner, types: self.types)
    }

    func emit(content html:inout HTML.ContentEncoder)
    {
        html[.section, { $0.class = "introduction" }]
        {
            $0[.div, { $0.class = "eyebrows" }]
            {
                $0[.span] { $0.class = "phylum" } = "Article"

                $0[.span, { $0.class = "module" }]
                {
                    $0[link: self.inliner.url(self.master.culture)] = self.stem.first

                    $0[.span, { $0.class = "culture" }]
                    {
                        $0[.span] { $0.class = "version" } = self.zone.version
                    }
                }
            }

            $0[.h1] = self.master.headline.safe

            $0 ?= (self.master.overview?.markdown).map(self.inliner.passage(_:))

            if  let file:Unidoc.Scalar = self.master.file
            {
                $0 ?= self.inliner.link(file: file)
            }
        }

        html[.section, { $0.class = "details" }] =
            (self.master.details?.markdown).map(self.inliner.passage(_:))
    }
}
