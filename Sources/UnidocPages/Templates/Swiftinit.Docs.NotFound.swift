import HTML
import UnidocRecords
import URI

extension Swiftinit.Docs
{
    struct NotFound
    {
        let context:IdentifiablePageContext<Never?>
        let sidebar:HTML.Sidebar<Swiftinit.Docs>?

        init(_ context:IdentifiablePageContext<Never?>, sidebar:HTML.Sidebar<Swiftinit.Docs>?)
        {
            self.context = context
            self.sidebar = sidebar
        }
    }
}
extension Swiftinit.Docs.NotFound:RenderablePage, DynamicPage
{
    var title:String { "Symbol Not Found - \(self.volume.title) Documentation" }
}
extension Swiftinit.Docs.NotFound:ApplicationPage
{
    typealias Navigator = HTML.Logo
}
extension Swiftinit.Docs.NotFound:VersionedPage
{
    var canonical:CanonicalVersion? { nil }

    func main(_ main:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
    {
        main[.section]
        {
            $0[.p]
            {
                $0 += "Symbol not found. Try a search, or return to the documentation for "
                $0[.a] { $0.href = "\(Swiftinit.Docs[self.volume])" } = self.volume.title
                $0 += "."
            }

            $0[.img]
            {
                $0.width = "400"
                $0.src = "\(format.assets[.error404_jpg])"
                $0.title = "This usually happens when package authors rename symbols."
                $0.alt = "margot robbie as barbie laying sideways on artificial grass"
            }
        }
    }
}
