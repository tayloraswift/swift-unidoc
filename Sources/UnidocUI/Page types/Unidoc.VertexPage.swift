import HTML
import JSON
import Unidoc
import UnidocRecords
import UnidocRender
import URI

extension Unidoc
{
    public
    protocol VertexPage:RenderablePage
    {
        associatedtype Context:VertexContext
        associatedtype Sidebar:HTML.OutputStreamable

        var sidebar:Sidebar { get }
        var context:Context { get }

        func main(_:inout HTML.ContentEncoder, format:RenderFormat)
    }
}
extension Unidoc.VertexPage where Self:Unidoc.StaticPage
{
    @inlinable public
    var canonicalURI:URI? { self.context.canonical?.uri }
}
extension Unidoc.VertexPage
{
    var volume:Unidoc.VolumeMetadata { self.context.volume }

    public
    func head(augmenting head:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
    {
        let json:JSON = .array
        {
            $0
            {
                $0["id"] = "\(self.volume.symbol)"
                $0["trunk"] = "\(Unidoc.DocsEndpoint[self.volume])"
            }

            for dependency:Unidoc.VolumeMetadata.Dependency in self.volume.dependencies
            {
                if  let dependency:Unidoc.Edition = dependency.pin?.linked,
                    let dependency:Unidoc.VolumeMetadata = self.context[dependency]
                {
                    $0
                    {
                        $0["id"] = "\(dependency.symbol)"
                        $0["trunk"] = "\(Unidoc.DocsEndpoint[dependency])"
                    }
                }
            }
        }

        head[unsafe: .script] = format.assets.script(volumes: json)
        head[unsafe: .script] { $0.type = "ld+json" } = self.context.structuredData
    }

    public
    func body(_ body:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
    {
        body[.div, { $0.class = "app navigator" }]
        {
            $0[.div] { $0.class = "sidebar" }
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
                            Search for types in the current package, including types from
                            dependencies, or for any package on Unidoc.

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
                    $0[.div]
                    {
                        $0[.ol] { $0.id = "search-results" }
                    }
                }
            }
            $0[.div] { $0.class = "sidebar" }
        }

        body[.div, { $0.class = "app" }]
        {
            $0[.div] { $0.class = "sidebar" ; $0.id = "sidebar-intrapage" }
            $0[.main] { self.main(&$0, format: format) }
            $0[.div] { $0.class = "sidebar" ; $0.id = "sidebar-interpage" } = self.sidebar
        }

        body[.div]
        {
            $0.style = "display: none;"
            $0.id = "ss:tooltips"
        } = self.context.tooltips
    }
}
