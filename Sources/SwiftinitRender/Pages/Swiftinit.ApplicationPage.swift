import HTML
import UnidocRecords
import URI

extension Swiftinit
{
    public
    protocol ApplicationPage<Navigator>:RenderablePage
    {
        associatedtype Navigator:HTML.OutputStreamable
        var navigator:Navigator { get }

        func main(_:inout HTML.ContentEncoder, format:RenderFormat)
    }
}
extension Swiftinit.ApplicationPage<HTML.Logo>
{
    @inlinable public
    var navigator:HTML.Logo { .init() }
}
extension Swiftinit.ApplicationPage
{
    public
    func head(augmenting head:inout HTML.ContentEncoder, format:Swiftinit.RenderFormat)
    {
        head[unsafe: .script] = format.assets.script(volumes: nil)
    }

    public
    func body(_ body:inout HTML.ContentEncoder, format:Swiftinit.RenderFormat)
    {
        body[.header, { $0.class = "app" }]
        {
            $0[.div, { $0.class = "content" }]
            {
                $0[.nav] = self.navigator

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
