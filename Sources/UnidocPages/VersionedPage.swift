import HTML
import UnidocRecords
import URI

public
protocol VersionedPage:ApplicationPage
{
    associatedtype Sidebar:HyperTextOutputStreamable

    var canonical:CanonicalVersion? { get }
    var sidebar:Sidebar? { get }

    var volume:Volume.Meta { get }
}
extension VersionedPage
{
    @inlinable public
    var canonical:CanonicalVersion? { nil }
}
extension VersionedPage where Self:StaticPage
{
    @inlinable public
    var canonicalURI:URI? { self.canonical?.uri }
}
extension VersionedPage where Sidebar == Never
{
    @inlinable public
    var sidebar:Never? { nil }
}
extension VersionedPage
{
    public
    func head(augmenting head:inout HTML.ContentEncoder)
    {
        head[unsafe: .script] = """
        const volumes = ["\(self.volume.symbol)"];
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
