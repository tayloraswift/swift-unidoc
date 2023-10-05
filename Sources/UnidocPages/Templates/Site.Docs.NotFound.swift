import HTML
import UnidocRecords
import URI

extension Site.Docs
{
    struct NotFound
    {
        let context:VersionedPageContext
        let sidebar:[Volume.Noun]?

        init(_ context:VersionedPageContext, sidebar:[Volume.Noun]?)
        {
            self.context = context
            self.sidebar = sidebar
        }
    }
}
extension Site.Docs.NotFound:RenderablePage, DynamicPage
{
    var title:String { "Symbol Not Found - \(self.volume.title) Documentation" }
}
extension Site.Docs.NotFound:ApplicationPage
{
    typealias Navigator = HTML.Logo
}
extension Site.Docs.NotFound:VersionedPage
{
    var canonical:CanonicalVersion? { nil }

    func main(_ main:inout HTML.ContentEncoder)
    {
        main[.section]
        {
            $0[.p]
            {
                $0 += "Symbol not found. Try a search, or return to the documentation for "
                $0[.a] { $0.href = "\(Site.Docs[self.volume])" } = self.volume.title
                $0 += "."
            }
        }
    }
}
