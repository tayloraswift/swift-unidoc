import HTML
import HTTPServer
import UnidocRecords
import URI

public
protocol FixedPage
{
    associatedtype Sidebar:HyperTextOutputStreamable = Never
    associatedtype Zone = Never?

    var location:URI { get }
    var title:String { get }
    var zone:Zone { get }

    var sidebar:Sidebar? { get }

    func emit(header:inout HTML.ContentEncoder)
    func emit(content:inout HTML.ContentEncoder)
}
extension FixedPage where Sidebar == Never
{
    @inlinable public
    var sidebar:Sidebar? { nil }
}
extension FixedPage where Zone == Never?
{
    @inlinable public
    var zone:Zone { nil }
}
extension FixedPage
{
    public
    func emit(header:inout HTML.ContentEncoder)
    {
        header[.nav, { $0.class = "default" }]
        {
            $0[.div]
            {
                $0[.a, { $0.class = "logo" ; $0.href = "/" }] = "swiftinit"
            }
        }
    }
}
extension FixedPage
{
    public
    func rendered() -> ServerResource
    {
        let location:String = "\(self.location)"

        //  TODO: factor this into something that doesn’t use a dynamic cast
        let nouns:String
        if  case let zone as Record.Zone = self.zone
        {
            nouns = """
            nouns = ["\(Site.NounMaps[zone])"];
            """
        }
        else
        {
            nouns = ""
        }

        let html:HTML = .document
        {
            $0[.html, { $0.lang = "en" }]
            {
                $0[.head]
                {
                    $0[.title] = self.title
                    $0[.meta] { $0.charset = "UTF-8" }
                    $0[.meta]
                    {
                        $0.name     = "viewport"
                        $0.content  = "width=device-width, initial-scale=1"
                    }
                    $0[.link] { $0.href = "\(Site.Asset.main_css)" ; $0.rel = .stylesheet }
                    $0[.script] { $0.src = "\(Site.Asset.main_js)" ; $0.defer = true }

                    $0[unsafe: .script] = nouns + """
                    history.replaceState(null, "", "\(location)");
                    """
                    //  Inlining this saves the client a round-trip to the google fonts API.
                    //  It is only about 1.87 KB, which is less than 5 percent of the total
                    //  size of a typical page.
                    $0[unsafe: .style] = Self.FontFaces
                }

                $0[.body]
                {
                    $0[.div, { $0.class = "content" }]
                    {
                        $0[.header, content: self.emit(header:)]
                        $0[.main, content: self.emit(content:)]
                    }
                    $0[.div] { $0.class = "sidebar" } = self.sidebar
                }
            }
        }
        return .init(.one(canonical: location),
                content: .binary(html.utf8),
                type: .text(.html, charset: .utf8))
    }
}
