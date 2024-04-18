import HTML
import MarkdownABI
import MarkdownRendering
import Unidoc
import UnidocRecords
import URI

extension Unidoc.DocsEndpoint
{
    struct ModulePage
    {
        let sidebar:Unidoc.Sidebar<Unidoc.DocsEndpoint>?
        let cone:Unidoc.Cone
        let apex:Unidoc.CultureVertex

        init(sidebar:Unidoc.Sidebar<Unidoc.DocsEndpoint>?,
            cone:Unidoc.Cone,
            apex:Unidoc.CultureVertex)
        {
            self.sidebar = sidebar
            self.apex = apex
            self.cone = cone
        }
    }
}
extension Unidoc.DocsEndpoint.ModulePage
{
    private
    var demonym:Unidoc.ModuleDemonym
    {
        .init(
            language: self.apex.module.language ?? .swift,
            type: self.apex.module.type)
    }

    private
    var name:String { self.apex.module.name }

    private
    var stem:Unidoc.Stem { self.apex.stem }
}
extension Unidoc.DocsEndpoint.ModulePage:Unidoc.RenderablePage
{
    var title:String { "\(self.name) · \(self.volume.title) Documentation" }
}
extension Unidoc.DocsEndpoint.ModulePage:Unidoc.StaticPage
{
    var location:URI { Unidoc.DocsEndpoint[self.volume, self.apex.route] }
}
extension Unidoc.DocsEndpoint.ModulePage:Unidoc.ApplicationPage
{
    typealias Navigator = HTML.Logo
}
extension Unidoc.DocsEndpoint.ModulePage:Unidoc.ApicalPage
{
    var descriptionFallback:String
    {
        if  case .swift = self.volume.symbol.package
        {
            "\(self.name) is \(self.demonym.phrase) in the Swift standard library."
        }
        else
        {
            "\(self.name) is \(self.demonym.phrase) in the \(self.volume.title) package."
        }
    }

    func main(_ main:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
    {
        main[.section, { $0.class = "introduction" }]
        {
            $0[.div, { $0.class = "eyebrows" }]
            {
                $0[.span] { $0.class = "phylum" } = self.demonym.title
                $0[.span, { $0.class = "domain" }]
                {
                    $0[.span, { $0.class = "volume" }]
                    {
                        $0[.a]
                        {
                            $0.href = "\(Unidoc.DocsEndpoint[self.volume])"
                        } = "\(self.volume.symbol.package) \(self.volume.symbol.version)"
                    }

                    $0[.span] { $0.class = "jump" } = self.stem.first
                }
            }

            $0[.h1] = self.name

            $0 ?= self.cone.overview

            if  let readme:Unidoc.Scalar = self.apex.readme
            {
                $0 ?= self.context.link(source: readme)
            }
        }

        main[.section] { $0.class = "notice canonical" } = self.context.canonical

        switch self.apex.module.type
        {
        case .binary, .regular, .macro, .system:
            main[.section, { $0.class = "declaration" }]
            {
                $0[.pre]
                {
                    $0[.code]
                    {
                        $0[.span] { $0.highlight = .keyword } = "import"
                        $0 += " "
                        $0[.span] { $0.highlight = .identifier } = self.stem.first
                    }
                }
            }
        case .executable, .plugin, .snippet, .test:
            main[.section, { $0.class = "notice" }]
            {
                $0[.p] = "This module is \(self.demonym.phrase). It cannot be imported."
            }
        }

        main[.section]
        {
            $0.class = "details"
        }
            content:
        {
            switch self.apex.module.type
            {
            case .binary, .regular, .macro:
                $0[.h2] = "Module Information"

                let decls:Int = self.apex.census.unweighted.decls.total
                let symbols:Int = self.apex.census.weighted.decls.total

                $0[.dl]
                {
                    $0[.dt] = "Declarations"
                    $0[.dd] = "\(decls)"

                    $0[.dt] = "Symbols"
                    $0[.dd] = "\(symbols)"
                }

                guard decls > 0
                else
                {
                    break
                }

                $0[.div] { $0.class = "more" } = Unidoc.StatsThumbnail.init(
                    target: Unidoc.StatsEndpoint[self.volume, self.apex.route],
                    census: self.apex.census,
                    domain: self.name,
                    title: "Module stats and coverage details")

            default:
                break
            }
        }

        main[.section, { $0.class = "details literature" }] = self.cone.details

        main += self.cone.halo
    }
}
