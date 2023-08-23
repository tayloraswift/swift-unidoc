import HTML
import URI

public
protocol ApplicationPage:FixedPage
{
    associatedtype Navigator:HyperTextOutputStreamable
    associatedtype Sidebar:HyperTextOutputStreamable

    var navigator:Navigator { get }
    var sidebar:Sidebar? { get }
    var search:URI { get }

    func main(_:inout HTML.ContentEncoder)
}
extension ApplicationPage where Navigator == HTML.Logo
{
    var navigator:HTML.Logo { .init() }
}
extension ApplicationPage where Sidebar == Never
{
    @inlinable public
    var sidebar:Never? { nil }
}
extension ApplicationPage
{
    public
    func head(augmenting head:inout HTML.ContentEncoder)
    {
        head[unsafe: .script] = """
        const nouns = ["\(self.search)"];
        """
    }
    public
    func body(_ body:inout HTML.ContentEncoder)
    {
        let sidebar:Sidebar? = self.sidebar

        body[.header]
        {
            $0[.div, { $0.class = "content" }]
            {
                $0[.nav] = self.navigator
                $0[.div, { $0.class = "searchbar-container" }]
                {
                    $0[.div, { $0.class = "searchbar" }]
                    {
                        $0[.form, { $0.id = "search" ; $0.role = "search" }]
                        {
                            $0[.input]
                            {
                                $0.id = "search-input"
                                $0.type = "search"
                                $0.placeholder = "search symbols"
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
            $0[.div] { $0.class = "sidebar" } = sidebar.map { _ in "" }
        }
        body[.div]
        {
            $0[.main, { $0.class = "content" }, content: self.main(_:)]
            $0[.div] { $0.class = "sidebar" } = sidebar
        }
    }
}