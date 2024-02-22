import HTML
import HTTP
import Media

extension Swiftinit
{
    public
    typealias RenderablePage = _SwiftinitRenderablePage
}

public
protocol _SwiftinitRenderablePage
{
    /// A short description of the page, suitable for use as a `<meta>` description.
    var description:String? { get }
    var title:String { get }

    func head(augmenting head:inout HTML.ContentEncoder, format:Swiftinit.RenderFormat)
    func body(_          body:inout HTML.ContentEncoder, format:Swiftinit.RenderFormat)

    func resource(format:Swiftinit.RenderFormat) -> HTTP.Resource
}
extension Swiftinit.RenderablePage
{
    @inlinable public
    var description:String? { nil }

    @inlinable public
    func head(augmenting    _:inout HTML.ContentEncoder, format:Swiftinit.RenderFormat)
    {
    }
}
extension Swiftinit.RenderablePage
{
    func rendered(
        canonical:String? = nil,
        location:String? = nil,
        format:Swiftinit.RenderFormat) -> HTML
    {
        .document
        {
            self.render(to: &$0,
                canonical: canonical,
                location: location,
                format: format)
        }
    }

    private
    func render(to html:inout HTML.ContentEncoder,
        canonical:String?,
        location:String?,
        format:Swiftinit.RenderFormat)
    {
        html[.html, { $0.lang = "en" }]
        {
            $0[.head]
            {
                let favicon:String = "\(format.assets[.favicon_png])"

                $0[.title] = self.title
                $0[.meta] { $0.charset = "UTF-8" }
                $0[.meta]
                {
                    $0.name = "viewport"
                    $0.content = "width=device-width, initial-scale=1"
                }
                $0[.link]
                {
                    $0.href = favicon
                    $0.type = "\(MediaType.image(.png))"
                    $0.rel = .icon
                }
                $0[.link]
                {
                    $0.href = "\(format.assets[.main_css])"
                    $0.rel = .stylesheet
                }
                if  let canonical:String = canonical ?? location
                {
                    $0[.link]
                    {
                        $0.href = "https://swiftinit.org\(canonical)"
                        $0.rel = .canonical
                    }
                }
                //  Inlining this saves the client a round-trip to the google fonts API.
                //  It is only about 1.87 KB, which is less than 5 percent of the total
                //  size of a typical page.
                $0[unsafe: .style] = format.assets.fontfaces

                if  let location:String
                {
                    $0[unsafe: .script] = """
                    history.replaceState(null, "", "\(location)" + window.location.hash);
                    """
                }

                $0[.script] { $0.src = "\(format.assets[.main_js])" ; $0.defer = true }

                if  let description:String = self.description
                {
                    //  It is regrettable that we need to duplicate the description text here,
                    //  particularly because we do not compress dynamic content. However, it is
                    //  necessary for Onebox to render link previews correctly.
                    $0[.meta] { $0.name = "description" ; $0.content  = description }
                    $0[.meta] { $0.property = .og_description ; $0.content = description }
                }
                else
                {
                    $0[.meta]
                    {
                        $0.property = .og_description
                        $0.content = "No overview available"
                    }
                }

                $0[.meta] { $0.property = .og_title ; $0.content = self.title }
                $0[.meta] { $0.property = .og_image ; $0.content = favicon }

                self.head(augmenting: &$0, format: format)
            }

            $0[.body] { self.body(&$0, format: format) }
        }
    }
}
