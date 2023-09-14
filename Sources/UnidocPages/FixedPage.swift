import HTML
import HTTP
import Media
import URI

public
protocol FixedPage
{
    /// A short description of the page, suitable for use as a `<meta>` description.
    var description:String? { get }
    var location:URI { get }
    var title:String { get }

    func head(augmenting head:inout HTML.ContentEncoder)
    func body(_          body:inout HTML.ContentEncoder)
}
extension FixedPage
{
    @inlinable public
    var description:String? { nil }

    @inlinable public
    func head(augmenting    _:inout HTML.ContentEncoder)
    {
    }
}
extension FixedPage where Self:FixedRoot
{
    @inlinable public
    var location:URI { Self.uri }
}
extension FixedPage
{
    public
    func rendered() -> ServerResource
    {
        let location:String = "\(self.location)"
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
                    $0[.link]
                    {
                        $0.href = "\(Site.Asset[.favicon_png])"
                        $0.type = "\(MediaType.image(.png))"
                        $0.rel = .icon
                    }
                    $0[.link]
                    {
                        $0.href = "\(Site.Asset[.main_css])"
                        $0.rel = .stylesheet
                    }
                    //  Inlining this saves the client a round-trip to the google fonts API.
                    //  It is only about 1.87 KB, which is less than 5 percent of the total
                    //  size of a typical page.
                    $0[unsafe: .style] = Self.FontFaces
                    $0[unsafe: .script] = """
                    history.replaceState(null, "", "\(location)");
                    """

                    $0[.script] { $0.src = "\(Site.Asset[.main_js])" ; $0.defer = true }

                    if  let description:String = self.description
                    {
                        $0[.meta] { $0.name = "description" ; $0.content  = description }
                    }

                    self.head(augmenting: &$0)
                }

                $0[.body]
                {
                    self.body(&$0)
                }
            }
        }
        return .init(.one(canonical: location),
                content: .binary(html.utf8),
                type: .text(.html, charset: .utf8))
    }
}
