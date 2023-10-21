import HTML
import UnidocRecords
import URI

public
protocol ApplicationPage<Navigator>:RenderablePage
{
    associatedtype Navigator:HyperTextOutputStreamable
    var navigator:Navigator { get }

    func main(_:inout HTML.ContentEncoder)
}
extension ApplicationPage<HTML.Logo>
{
    var navigator:HTML.Logo { .init() }
}
extension ApplicationPage
{
    public
    func head(augmenting head:inout HTML.ContentEncoder, assets:StaticAssets)
    {
        head[unsafe: .script] = "const volumes = [];"
    }

    public
    func body(_ body:inout HTML.ContentEncoder)
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
        body[.div]
        {
            $0[.main, { $0.class = "content" }, content: self.main(_:)]
        }
    }
}
