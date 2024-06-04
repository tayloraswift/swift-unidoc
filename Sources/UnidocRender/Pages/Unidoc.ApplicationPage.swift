import HTML
import UnidocRecords
import URI

extension Unidoc
{
    public
    protocol ApplicationPage<Cornice>:RenderablePage
    {
        associatedtype Cornice:HTML.OutputStreamable

        func cornice(format:RenderFormat) -> Cornice
        func main(_:inout HTML.ContentEncoder, format:RenderFormat)
    }
}
extension Unidoc.ApplicationPage<Unidoc.ApplicationCornice>
{
    public
    func cornice(format:Unidoc.RenderFormat) -> Unidoc.ApplicationCornice
    {
        if  case .swiftinit_org = format.server
        {
            .init(official: true)
        }
        else
        {
            .init(official: false)
        }
    }
}
extension Unidoc.ApplicationPage
{
    public
    func head(augmenting head:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
    {
        head[unsafe: .script] = format.assets.script(volumes: nil)
    }

    public
    func body(_ body:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
    {
        body[.header, { $0.class = "app" }]
        {
            $0[.div, { $0.class = "content" }]
            {
                $0[.nav] { $0.class = "cornice" } = self.cornice(format: format)
                $0[.div, { $0.class = "searchbar-container" }]
                {
                    $0[.div]
                    {
                        $0.class = "searchbar"
                        $0.title = """
                        Search for any package on Swiftinit.

                        Shortcut: /
                        """
                    }
                        content:
                    {
                        $0[.form, { $0.id = "search" ; $0.role = "search" }]
                        {
                            $0[.input]
                            {
                                $0.id = "search-input"
                                $0.type = "search"
                                $0.placeholder = "search packages"
                                $0.autocomplete = "off"
                            }
                        }
                    }
                }
                $0[.div, { $0.class = "search-results-container" }]
                {
                    $0[.ol] { $0.id = "search-results" }
                }
            }
        }
        body[.div, { $0.class = "app" }]
        {
            $0[.main, { $0.class = "content" }] { self.main(&$0, format: format) }
        }
    }
}
