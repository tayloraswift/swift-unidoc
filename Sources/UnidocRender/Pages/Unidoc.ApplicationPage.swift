import HTML
import UnidocRecords
import URI

extension Unidoc
{
    public
    protocol ApplicationPage:RenderablePage
    {
        func main(_:inout HTML.ContentEncoder, format:RenderFormat)
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
        body[.div, { $0.class = "app navigator" }]
        {
            $0[.header]
            {
                $0[.nav] = format.cornice
                $0[.div, { $0.class = "search" }]
                {
                    $0[.div]
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
                    $0[.div]
                    {
                        $0[.ol] { $0.id = "search-results" }
                    }
                }
            }
        }
        body[.div, { $0.class = "app" }]
        {
            $0[.main] { self.main(&$0, format: format) }
        }
    }
}
