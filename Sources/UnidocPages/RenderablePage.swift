import HTML
import HTTP
import Media

public
protocol RenderablePage
{
    /// A short description of the page, suitable for use as a `<meta>` description.
    var description:String? { get }
    var title:String { get }

    func head(augmenting head:inout HTML.ContentEncoder, assets:StaticAssets)
    func body(_          body:inout HTML.ContentEncoder, assets:StaticAssets)

    func resource(assets:StaticAssets) -> HTTP.Resource
}
extension RenderablePage
{
    @inlinable public
    var description:String? { nil }

    @inlinable public
    func head(augmenting    _:inout HTML.ContentEncoder, assets:StaticAssets)
    {
    }
}
extension RenderablePage
{
    func rendered(
        canonical:String? = nil,
        location:String? = nil,
        assets:StaticAssets) -> HTML
    {
        .document
        {
            self.render(to: &$0,
                canonical: canonical,
                location: location,
                assets: assets)
        }
    }

    private
    func render(to html:inout HTML.ContentEncoder,
        canonical:String?,
        location:String?,
        assets:StaticAssets)
    {
        html[.html, { $0.lang = "en" }]
        {
            $0[.head]
            {
                $0[.title] = self.title
                $0[.meta] { $0.charset = "UTF-8" }
                $0[.meta]
                {
                    $0.name = "viewport"
                    $0.content = "width=device-width, initial-scale=1"
                }
                $0[.link]
                {
                    $0.href = "\(assets[.favicon_png])"
                    $0.type = "\(MediaType.image(.png))"
                    $0.rel = .icon
                }
                $0[.link]
                {
                    $0.href = "\(assets[.main_css])"
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
                $0[unsafe: .style] = assets.fontfaces

                if  let location:String
                {
                    $0[unsafe: .script] = """
                    history.replaceState(null, "", "\(location)" + window.location.hash);
                    """
                }

                $0[.script] { $0.src = "\(assets[.main_js])" ; $0.defer = true }

                if  let description:String = self.description
                {
                    $0[.meta] { $0.name = "description" ; $0.content  = description }
                }

                self.head(augmenting: &$0, assets: assets)
            }

            $0[.body] { self.body(&$0, assets: assets) }
        }
    }
}
