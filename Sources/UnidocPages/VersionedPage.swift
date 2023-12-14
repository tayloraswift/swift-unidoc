import HTML
import JSON
import Unidoc
import UnidocRecords
import URI

public
protocol VersionedPage:ApplicationPage
{
    associatedtype Context:VersionedPageContext
    associatedtype Sidebar:HyperTextOutputStreamable

    var canonical:CanonicalVersion? { get }
    var sidebar:Sidebar? { get }

    var context:Context { get }
}
extension VersionedPage where Self:StaticPage
{
    @inlinable public
    var canonicalURI:URI? { self.canonical?.uri }
}
extension VersionedPage
{
    var volume:Unidoc.VolumeMetadata { self.context.volume }

    public
    func head(augmenting head:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
    {
        let json:JSON = .array
        {
            $0[+, Any.self]
            {
                $0["id"] = "\(self.volume.symbol)"
                $0["trunk"] = "\(Site.Docs[self.volume])"
            }

            for dependency:Unidoc.VolumeMetadata.Dependency in self.volume.dependencies
            {
                if  let dependency:Unidoc.Edition = dependency.pinned,
                    let dependency:Unidoc.VolumeMetadata = self.context[dependency]
                {
                    $0[+, Any.self]
                    {
                        $0["id"] = "\(dependency.symbol)"
                        $0["trunk"] = "\(Site.Docs[dependency])"
                    }
                }
            }
        }

        head[unsafe: .script] = format.assets.script(volumes: json)
    }

    public
    func body(_ body:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
    {
        let sidebar:Sidebar? = self.sidebar

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
                        Search for types in the current package, including types from
                        dependencies, or for any package on Swiftinit.

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
                                $0.placeholder = "search documentation"
                                $0.autocomplete = "off"
                            }
                        }
                    }

                    $0[.label]
                    {
                        $0.class = "checkbox"
                        $0.title = """
                        Search for packages only.

                        Shortcut: ,
                        """
                    }
                        content:
                    {
                        $0[.input]
                        {
                            $0.id = "search-packages-only"
                            $0.type = "checkbox"
                        }

                        $0[.span] = "packages only"
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
            $0[.main, { $0.class = "content" }] { self.main(&$0, format: format) }
            $0[.div] { $0.class = "sidebar" } = sidebar
        }
    }
}
