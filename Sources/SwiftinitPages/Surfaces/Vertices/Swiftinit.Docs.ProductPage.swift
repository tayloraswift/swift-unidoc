import HTML
import SwiftinitRender
import UnidocRecords
import URI

extension Swiftinit.Docs
{
    struct ProductPage
    {
        let context:IdentifiablePageContext<Unidoc.Scalar>

        let canonical:CanonicalVersion?

        private
        let vertex:Unidoc.ProductVertex
        private
        let groups:GroupSections

        init(_ context:IdentifiablePageContext<Unidoc.Scalar>,
            canonical:CanonicalVersion?,
            vertex:Unidoc.ProductVertex,
            groups:GroupSections)
        {
            self.context = context
            self.canonical = canonical
            self.vertex = vertex
            self.groups = groups
        }
    }
}
extension Swiftinit.Docs.ProductPage
{
    private
    var demonym:Swiftinit.ProductDemonym
    {
        .init(type: self.vertex.type)
    }
}
extension Swiftinit.Docs.ProductPage:Swiftinit.RenderablePage
{
    var title:String { "\(self.vertex.symbol) · \(self.volume.title) Products" }

    var description:String?
    {
        """
        \(self.vertex.symbol) is \(self.demonym.phrase) \
        available in the package \(self.volume.title)".
        """
    }
}
extension Swiftinit.Docs.ProductPage:Swiftinit.StaticPage
{
    var location:URI { Swiftinit.Docs[self.volume, self.vertex.route] }
}
extension Swiftinit.Docs.ProductPage:Swiftinit.ApplicationPage
{
    typealias Navigator = HTML.Logo
}
extension Swiftinit.Docs.ProductPage:Swiftinit.VertexPage
{
    var sidebar:Swiftinit.Sidebar<Swiftinit.Docs>? { .product(volume: self.volume) }

    func main(_ main:inout HTML.ContentEncoder, format:Swiftinit.RenderFormat)
    {
        main[.section, { $0.class = "introduction" }]
        {
            $0[.div, { $0.class = "eyebrows" }]
            {
                $0[.span] { $0.class = "phylum" } = self.demonym.title
                $0[.span] { $0.class = "domain" } = self.context.domain
            }

            $0[.h1] = self.vertex.symbol
        }

        main[.section] { $0.class = "notice canonical" } = self.canonical

        //  Does this product contain a module with the same name as the product?
        for id:Unidoc.Scalar in self.vertex.requirements
        {
            guard
            case .culture(let vertex) = self.context.vertices[id],
                vertex.module.name == self.vertex.symbol
            else
            {
                continue
            }

            main[.section, { $0.class = "notice" }]
            {
                $0[.p]
                {
                    $0 += "This page is for the SwiftPM "
                    $0[.em] = "build product"
                    $0 += " named "
                    $0[.code] = self.vertex.symbol
                    $0 += "."
                }
                $0[.p]
                {
                    $0 += "The "
                    $0[.a]
                    {
                        $0.href = "\(Swiftinit.Docs[self.volume])"
                    } = self.volume.title
                    $0 += " package also contains "
                    $0[.a]
                    {
                        $0.href = "\(Swiftinit.Docs[self.volume, vertex.route])"
                    } = "a module"
                    $0 += " with the same name."
                }
            }

            break
        }

        main[.section, { $0.class = "details" }]
        {
            if  case .library(let type) = self.vertex.type
            {
                $0[.h2] = "Product Information"

                $0[.dl]
                {
                    $0[.dt] = "Linker mode"
                    $0[.dd] = switch type
                    {
                    case .automatic:    "automatic"
                    case .dynamic:      "dynamic"
                    case .static:       "static"
                    }
                }
            }

            $0[.h2] = AutomaticHeading.allProductConstituents

            $0[.table, { $0.class = "constituents" }]
            {
                $0[.thead]
                {
                    $0[.tr]
                    {
                        $0[.th] = "Name"
                        $0[.th] = "Dependency"
                    }
                }
                $0[.tbody]
                {
                    for id:Unidoc.Scalar in self.vertex.requirements
                    {
                        guard
                        let vertex:Unidoc.AnyVertex = self.context.vertices[id]
                        else
                        {
                            continue
                        }

                        $0[.tr]
                        {
                            switch vertex
                            {
                            case .culture(let vertex):
                                $0[.td]
                                {
                                    $0[.a]
                                    {
                                        $0.href = "\(Swiftinit.Docs[self.volume, vertex.route])"
                                    } = vertex.module.name
                                }
                                $0[.td]
                                {
                                    $0[.span] { $0.class = "placeholder" } = "none"
                                }

                            case .product(let vertex):
                                guard
                                let volume:Unidoc.VolumeMetadata =
                                    self.context.volumes[id.edition]
                                else
                                {
                                    return
                                }

                                $0[.td]
                                {
                                    $0[.a]
                                    {
                                        $0.href = "\(Swiftinit.Docs[volume, vertex.route])"
                                    } = vertex.symbol
                                }

                                $0[.td]
                                {
                                    $0[.a]
                                    {
                                        $0.href = "\(Swiftinit.Docs[volume])"
                                    } = "\(volume.symbol.package)"
                                }

                            default:
                                return
                            }
                        }
                    }
                }
            }
        }

        main += self.groups
    }
}
