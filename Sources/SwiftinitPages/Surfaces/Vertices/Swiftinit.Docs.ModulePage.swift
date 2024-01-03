import HTML
import MarkdownABI
import MarkdownRendering
import Unidoc
import UnidocRecords
import URI

extension Swiftinit.Docs
{
    struct ModulePage
    {
        let context:IdentifiablePageContext<Unidoc.Scalar>

        let canonical:CanonicalVersion?
        let sidebar:Swiftinit.Sidebar<Swiftinit.Docs>?

        private
        let vertex:Unidoc.CultureVertex
        private
        let groups:GroupSections

        init(_ context:IdentifiablePageContext<Unidoc.Scalar>,
            canonical:CanonicalVersion?,
            sidebar:Swiftinit.Sidebar<Swiftinit.Docs>?,
            vertex:Unidoc.CultureVertex,
            groups:GroupSections)
        {
            self.context = context
            self.canonical = canonical
            self.sidebar = sidebar
            self.vertex = vertex
            self.groups = groups
        }
    }
}
extension Swiftinit.Docs.ModulePage
{
    private
    var demonym:Swiftinit.ModuleDemonym
    {
        .init(
            language: self.vertex.module.language ?? .swift,
            type: self.vertex.module.type)
    }

    private
    var name:String { self.vertex.module.name }

    private
    var stem:Unidoc.Stem { self.vertex.stem }
}
extension Swiftinit.Docs.ModulePage:Swiftinit.RenderablePage
{
    var title:String { "\(self.name) · \(self.volume.title) Documentation" }

    var description:String?
    {
        if  let overview:MarkdownBytecode = self.vertex.overview?.markdown
        {
            "\(self.context.prose(overview))"
        }
        else if case .swift = self.volume.symbol.package
        {
            "\(self.name) is \(self.demonym.phrase) in the Swift standard library."
        }
        else
        {
            "\(self.name) is \(self.demonym.phrase) in the \(self.volume.title) package."
        }
    }
}
extension Swiftinit.Docs.ModulePage:Swiftinit.StaticPage
{
    var location:URI { Swiftinit.Docs[self.volume, self.vertex.shoot] }
}
extension Swiftinit.Docs.ModulePage:Swiftinit.ApplicationPage
{
    typealias Navigator = HTML.Logo
}
extension Swiftinit.Docs.ModulePage:Swiftinit.VertexPage
{
    func main(_ main:inout HTML.ContentEncoder, format:Swiftinit.RenderFormat)
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
                            $0.href = "\(Swiftinit.Docs[self.volume])"
                        } = "\(self.volume.symbol.package) \(self.volume.symbol.version)"
                    }

                    $0[.span] { $0.class = "jump" } = self.stem.first
                }
            }

            $0[.h1] = self.name

            $0 ?= (self.vertex.overview?.markdown).map(self.context.prose(_:))

            if  let readme:Unidoc.Scalar = self.vertex.readme
            {
                $0 ?= self.context.link(file: readme)
            }
        }

        main[.section] { $0.class = "notice canonical" } = self.canonical

        switch self.vertex.module.type
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
            switch self.vertex.module.type
            {
            case .binary, .regular, .macro:
                $0[.h2] = "Module Information"

                let decls:Int = self.vertex.census.unweighted.decls.total
                let symbols:Int = self.vertex.census.weighted.decls.total

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

                $0[.div] { $0.class = "more" } = Swiftinit.StatsThumbnail.init(
                    target: Swiftinit.Stats[self.volume, self.vertex.shoot],
                    census: self.vertex.census,
                    domain: self.name,
                    title: "Module stats and coverage details")

            default:
                break
            }

            $0 ?= (self.vertex.details?.markdown).map(self.context.prose(_:))
        }

        main += self.groups
    }
}
