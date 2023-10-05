import Availability
import HTML
import LexicalPaths
import MarkdownABI
import ModuleGraphs
import Signatures
import Sources
import Unidoc
import UnidocRecords
import URI

extension Site.Docs
{
    struct Decl
    {
        let context:VersionedPageContext

        let canonical:CanonicalVersion?
        let sidebar:[Volume.Noun]?

        private
        let vertex:Volume.Vertex.Decl
        private
        let groups:[Volume.Group]

        init(_ context:VersionedPageContext,
            canonical:CanonicalVersion?,
            sidebar:[Volume.Noun]?,
            vertex:Volume.Vertex.Decl,
            groups:[Volume.Group])
        {
            self.context = context
            self.canonical = canonical
            self.sidebar = sidebar
            self.vertex = vertex
            self.groups = groups
        }
    }
}
extension Site.Docs.Decl
{
    private
    var stem:Volume.Stem { self.vertex.stem }
}
extension Site.Docs.Decl:RenderablePage
{
    var title:String { "\(self.stem.last) - \(self.volume.title)" }

    var description:String?
    {
        if  let overview:MarkdownBytecode = self.vertex.overview?.markdown
        {
            return "\(self.context.prose(overview))"
        }

        let what:Demonym = .init(phylum: self.vertex.phylum, kinks: self.vertex.kinks)

        if  case .swift = self.volume.symbol.package
        {
            return """
                \(self.stem.last) is \(what) from the Swift standard library.
                """
        }
        else
        {
            return """
                \(self.stem.last) is \(what) from the package \
                \(self.volume.display ?? "\(self.volume.symbol.package)").
                """
        }
    }
}
extension Site.Docs.Decl:StaticPage
{
    var location:URI { Site.Docs[self.volume, self.vertex.shoot] }
}
extension Site.Docs.Decl:ApplicationPage
{
    var navigator:Breadcrumbs
    {
        if  let (_, scope, last):(Substring, [Substring], Substring) = self.stem.split()
        {
            .init(scope: self.vertex.scope.isEmpty ?
                    nil : self.context.vectorLink(components: scope, to: self.vertex.scope),
                last: last)
        }
        else
        {
            .init(scope: nil,
                last: self.stem.last)
        }
    }
}
extension Site.Docs.Decl:VersionedPage
{
    func main(_ main:inout HTML.ContentEncoder)
    {
        let groups:GroupSections = .init(self.context,
            requirements: self.vertex.requirements,
            superforms: self.vertex.superforms,
            generics: self.vertex.signature.generics.parameters,
            groups: self.groups,
            bias: self.vertex.culture,
            mode: .decl(self.vertex.phylum, self.vertex.kinks))

        main[.section]
        {
            $0.class = "introduction"
        }
            content:
        {
            $0[.div, { $0.class = "eyebrows" }]
            {
                let demonym:Demonym = .init(
                    phylum: self.vertex.phylum,
                    kinks: self.vertex.kinks)

                $0[.span] { $0.class = "phylum" } = demonym
                $0[.span, { $0.class = "domain" }]
                {
                    if  self.vertex.namespace != self.vertex.culture
                    {
                        $0[.span] { $0.class = "culture" } = self.context.link(
                            module: self.vertex.culture)

                        $0[.span, { $0.class = "volume" }]
                        {
                            $0[.a]
                            {
                                $0.href = "\(Site.Docs[self.volume])"
                            } = self.volume.symbol.version
                        }

                        $0[.span, { $0.class = "namespace" }]
                        {
                            $0[link: self.context.url(self.vertex.namespace)] = self.stem.first
                        }
                    }
                    else
                    {
                        $0[.span, { $0.class = "culture" }]
                        {
                            $0[link: self.context.url(self.vertex.namespace)] = self.stem.first
                        }

                        $0[.span, { $0.class = "volume" }]
                        {
                            $0[.a]
                            {
                                $0.href = "\(Site.Docs[self.volume])"
                            } = self.volume.symbol.version
                        }
                    }
                }
            }

            $0[.h1] = self.stem.last

            $0 ?= (self.vertex.overview?.markdown).map(self.context.prose(_:))

            if  let location:SourceLocation<Unidoc.Scalar> = self.vertex.location
            {
                $0 ?= self.context.link(file: location.file, line: location.position.line)
            }
        }

        if  let _:[String] = self.vertex.signature.spis
        {
            main[.section, { $0.class = "notice spi" }]
            {
                $0[.p] = """
                This declaration is gated by at least one @_spi attribute.
                """
            }
        }

        let availability:Availability = self.vertex.signature.availability
        if  let notice:String = availability.notice
        {
            main[.section, { $0.class = "notice deprecation" }] { $0[.p] = notice }
        }
        else if !availability.isEmpty
        {
            main[.section, { $0.class = "availability" }]
            {
                $0[.dl]
                {
                    if  let badge:String = availability.agnostic[.swift]?.badge
                    {
                        $0[.dt] = "Swift"
                        $0[.dd] = badge
                    }
                    if  let badge:String = availability.agnostic[.swiftPM]?.badge
                    {
                        $0[.dt] = "SwiftPM"
                        $0[.dd] = badge
                    }

                    for platform:Availability.PlatformDomain in
                        Availability.PlatformDomain.allCases
                    {
                        if  let badge:String = availability.platforms[platform]?.badge
                        {
                            $0[.dt] = "\(platform)"
                            $0[.dd] = badge
                        }
                    }
                }
            }
        }

        main[.section] { $0.class = "notice canonical" } = self.canonical

        main[.section, { $0.class = "declaration" }]
        {
            $0[.pre]
            {
                /// See note in `GroupList.Card.swift`.
                let width:Int = "\(self.vertex.signature.expanded.bytecode.safe)".count

                $0[.code]
                {
                    $0.class = width > 80 ? "multiline" : nil
                } = self.context.code(self.vertex.signature.expanded)
            }
        }

        main[.section] { $0.class = "details" } =
            (self.vertex.details?.markdown).map(self.context.prose(_:))

        main += groups
    }
}
