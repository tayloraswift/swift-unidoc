import HTML
import MarkdownRendering
import UnidocSelectors
import UnidocRecords
import URI

extension Site.Blog
{
    struct Article
    {
        private
        let inliner:Inliner

        private
        let master:Volume.Vertex.Article

        init(_ inliner:Inliner, master:Volume.Vertex.Article)
        {
            self.inliner = inliner
            self.master = master
        }
    }
}
extension Site.Blog.Article
{
    private
    var names:Volume.Names { self.inliner.names.principal }
}
extension Site.Blog.Article:FixedPage
{
    var location:URI
    {
        var uri:URI = []
            uri.path += self.master.stem
        return uri
    }

    var title:String { self.names.title }

    public
    func body(_ body:inout HTML.ContentEncoder)
    {
        body[.header]
        {
            $0[.div, { $0.class = "content" }] { $0[.nav] = HTML.Logo.init() }
        }
        body[.div]
        {
            $0[.main, { $0.class = "content" }]
            {
                $0[.section, { $0.class = "introduction" }]
                {
                    $0[.h1] = self.master.headline.safe

                }
                $0[.section, { $0.class = "details" }]
                {
                    $0 ?= (self.master.overview?.markdown).map(self.inliner.passage(_:))
                    $0 ?= (self.master.details?.markdown).map(self.inliner.passage(_:))
                }
            }
        }
    }
}
