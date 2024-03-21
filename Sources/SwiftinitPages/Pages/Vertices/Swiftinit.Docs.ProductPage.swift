import HTML
import SwiftinitRender
import UnidocRecords
import URI

extension Swiftinit.Docs
{
    struct ProductPage
    {
        let mesh:Swiftinit.Mesh
        let apex:Unidoc.ProductVertex

        init(mesh:Swiftinit.Mesh, apex:Unidoc.ProductVertex)
        {
            self.mesh = mesh
            self.apex = apex
        }
    }
}
extension Swiftinit.Docs.ProductPage
{
    private
    var demonym:Swiftinit.ProductDemonym
    {
        .init(type: self.apex.type)
    }
}
extension Swiftinit.Docs.ProductPage:Swiftinit.RenderablePage
{
    var title:String { "\(self.apex.symbol) · \(self.volume.title) Products" }
}
extension Swiftinit.Docs.ProductPage:Swiftinit.StaticPage
{
    var location:URI { Swiftinit.Docs[self.volume, self.apex.route] }
}
extension Swiftinit.Docs.ProductPage:Swiftinit.ApplicationPage
{
    typealias Navigator = HTML.Logo
}
extension Swiftinit.Docs.ProductPage:Swiftinit.ApicalPage
{
    var sidebar:Swiftinit.Sidebar<Swiftinit.Docs>? { .product(volume: self.volume) }

    var descriptionFallback:String
    {
        """
        \(self.apex.symbol) is \(self.demonym.phrase) \
        available in the package \(self.volume.title)".
        """
    }

    func main(_ main:inout HTML.ContentEncoder, format:Swiftinit.RenderFormat)
    {
        main[.section, { $0.class = "introduction" }]
        {
            $0[.div, { $0.class = "eyebrows" }]
            {
                $0[.span] { $0.class = "phylum" } = self.demonym.title
                $0[.span] { $0.class = "domain" } = self.context.domain
            }

            $0[.h1] = self.apex.symbol
        }

        main[.section] { $0.class = "notice canonical" } = self.context.canonical

        //  Does this product contain a module with the same name as the product?
        for id:Unidoc.Scalar in self.apex.constituents
        {
            guard
            case .culture(let vertex)? = self.context[id],
                vertex.module.name == self.apex.symbol
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
                    $0[.code] = self.apex.symbol
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
            if  case .library(let type) = self.apex.type
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
                    for id:Unidoc.Scalar in self.apex.constituents
                    {
                        guard
                        let volume:Unidoc.VolumeMetadata = self.context[id.edition],
                        let vertex:Unidoc.AnyVertex = self.context[id]
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
                                        $0.href = "\(Swiftinit.Docs[volume, vertex.route])"
                                    } = vertex.module.name
                                }
                                $0[.td]
                                {
                                    $0[.span] { $0.class = "placeholder" } = "none"
                                }

                            case .product(let vertex):
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

        main += self.mesh.halo
    }
}
