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
        let inliner:Inliner

        let canonical:CanonicalVersion?
        private
        let master:Volume.Vertex.Decl
        private
        let groups:[Volume.Group]
        private
        let nouns:[Volume.Noun]?

        init(_ inliner:Inliner,
            canonical:CanonicalVersion?,
            master:Volume.Vertex.Decl,
            groups:[Volume.Group],
            nouns:[Volume.Noun]?)
        {
            self.inliner = inliner
            self.canonical = canonical
            self.master = master
            self.groups = groups
            self.nouns = nouns
        }
    }
}
extension Site.Docs.Decl
{
    private
    var stem:Volume.Stem { self.master.stem }
}
extension Site.Docs.Decl:RenderablePage
{
    var title:String { "\(self.stem.last) - \(self.volume.title)" }

    var description:String?
    {
        if  let overview:MarkdownBytecode = self.master.overview?.markdown
        {
            return "\(self.inliner.passage(overview))"
        }

        let what:Demonym = .init(phylum: self.master.phylum, kinks: self.master.kinks)

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
    var location:URI { Site.Docs[self.volume, self.master.shoot] }
}
extension Site.Docs.Decl:ApplicationPage
{
    var navigator:Inliner.Breadcrumbs
    {
        if  let (_, scope, last):(Substring, [Substring], Substring) = self.stem.split()
        {
            return .init(
                scope: self.master.scope.isEmpty ?
                    nil : self.inliner.vectorLink(components: scope, to: self.master.scope),
                last: last)
        }
        else
        {
            return .init(
                scope: nil,
                last: self.stem.last)
        }
    }
}
extension Site.Docs.Decl:VersionedPage
{
    var sidebar:Inliner.TypeTree? { self.nouns.map { .init(self.inliner, nouns: $0) } }

    var volume:Volume.Meta { self.inliner.volumes.principal }

    func main(_ main:inout HTML.ContentEncoder)
    {
        let groups:Inliner.Groups = .init(self.inliner,
            requirements: self.master.requirements,
            superforms: self.master.superforms,
            generics: self.master.signature.generics.parameters,
            groups: self.groups,
            bias: self.master.culture,
            mode: .decl(self.master.phylum, self.master.kinks))

        main[.section]
        {
            $0.class = "introduction"
        }
            content:
        {
            $0[.div, { $0.class = "eyebrows" }]
            {
                let demonym:Demonym = .init(
                    phylum: self.master.phylum,
                    kinks: self.master.kinks)

                $0[.span] { $0.class = "phylum" } = demonym
                $0[.span, { $0.class = "domain" }]
                {
                    if  self.master.namespace != self.master.culture
                    {
                        $0[.span] { $0.class = "culture" } = self.inliner.link(
                            module: self.master.culture)

                        $0[.span, { $0.class = "volume" }]
                        {
                            $0[.a]
                            {
                                $0.href = "\(Site.Docs[self.volume])"
                            } = self.volume.symbol.version
                        }

                        $0[.span, { $0.class = "namespace" }]
                        {
                            $0[link: self.inliner.url(self.master.namespace)] = self.stem.first
                        }
                    }
                    else
                    {
                        $0[.span, { $0.class = "culture" }]
                        {
                            $0[link: self.inliner.url(self.master.namespace)] = self.stem.first
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

            $0 ?= (self.master.overview?.markdown).map(self.inliner.passage(_:))

            if  let location:SourceLocation<Unidoc.Scalar> = self.master.location
            {
                $0 ?= self.inliner.link(file: location.file, line: location.position.line)
            }
        }

        if  let _:[String] = self.master.signature.spis
        {
            main[.section, { $0.class = "notice spi" }]
            {
                $0[.p] = """
                This declaration is gated by at least one @_spi attribute.
                """
            }
        }

        let availability:Availability = self.master.signature.availability
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
                /// See note in `Inliner.Card.swift`.
                let width:Int = "\(master.signature.expanded.bytecode.safe)".count

                $0[.code]
                {
                    $0.class = width > 80 ? "multiline" : nil
                } = self.inliner.code(self.master.signature.expanded)
            }
        }

        main[.section] { $0.class = "details" } =
            (self.master.details?.markdown).map(self.inliner.passage(_:))

        main += groups
    }
}
