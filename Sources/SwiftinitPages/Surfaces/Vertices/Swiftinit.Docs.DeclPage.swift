import Availability
import FNV1
import HTML
import LexicalPaths
import MarkdownABI
import Signatures
import Sources
import Symbols
import Unidoc
import UnidocRecords
import URI

extension Swiftinit.Docs
{
    struct DeclPage
    {
        let context:IdentifiablePageContext<Unidoc.Scalar>

        let canonical:CanonicalVersion?
        let sidebar:Swiftinit.Sidebar<Swiftinit.Docs>?

        private
        let vertex:Unidoc.DeclVertex
        private
        let groups:GroupSections

        private
        let stem:Unidoc.StemComponents

        init(_ context:IdentifiablePageContext<Unidoc.Scalar>,
            canonical:CanonicalVersion?,
            sidebar:Swiftinit.Sidebar<Swiftinit.Docs>?,
            vertex:Unidoc.DeclVertex,
            groups:GroupSections) throws
        {
            self.context = context
            self.canonical = canonical
            self.sidebar = sidebar
            self.vertex = vertex
            self.groups = groups

            self.stem = try .init(vertex.stem)
        }
    }
}
extension Swiftinit.Docs.DeclPage
{
    private
    var demonym:Swiftinit.DeclDemonym
    {
        .init(phylum: self.vertex.phylum, kinks: self.vertex.kinks)
    }
}
extension Swiftinit.Docs.DeclPage:Swiftinit.RenderablePage
{
    var title:String { "\(self.stem.last) · \(self.volume.title) Documentation" }

    var description:String?
    {
        if  let overview:MarkdownBytecode = self.vertex.overview?.markdown
        {
            "\(self.context.prose(overview))"
        }
        else if case .swift = self.volume.symbol.package
        {
            """
            \(self.stem.last) is \(self.demonym.phrase) from the Swift standard library.
            """
        }
        else
        {
            """
            \(self.stem.last) is \(self.demonym.phrase) from the package \(self.volume.title).
            """
        }
    }
}
extension Swiftinit.Docs.DeclPage:Swiftinit.StaticPage
{
    var location:URI { Swiftinit.Docs[self.volume, self.vertex.route] }
}
extension Swiftinit.Docs.DeclPage:Swiftinit.ApplicationPage
{
    typealias Navigator = HTML.Logo
}
extension Swiftinit.Docs.DeclPage:Swiftinit.VertexPage
{
    func main(_ main:inout HTML.ContentEncoder, format:Swiftinit.RenderFormat)
    {
        main[.section, { $0.class = "introduction" }]
        {
            $0[.div, { $0.class = "eyebrows" }]
            {
                $0[.span, { $0.class = "phylum" }]
                {
                    if  let kink:String = self.demonym.modifier
                    {
                        $0[.span, { $0.class = "kink" }] = kink
                        $0 += " "
                    }

                    $0 += self.demonym.title

                    if  self.vertex.kinks[is: .intrinsicWitness]
                    {
                        $0 += " (Default Implementation)"
                    }
                }

                $0[.span, { $0.class = "domain" }] = self.context.subdomain(self.stem.namespace,
                    namespace: self.vertex.namespace,
                    culture: self.vertex.culture)
            }

            $0[.nav] { $0.class = "breadcrumbs" } = self.context.vector(self.vertex.scope,
                display: self.stem.scope)

            $0[.h1] = self.stem.last

            $0 ?= (self.vertex.overview?.markdown).map(self.context.prose(_:))

            if  let location:SourceLocation<Unidoc.Scalar> = self.vertex.location
            {
                $0 ?= self.context.link(file: location.file, line: location.position.line)
            }
            if  let file:Unidoc.Scalar = self.vertex.readme
            {
                $0 ?= self.context.link(file: file)
            }
        }

        if  let _:[String] = self.vertex.signature.spis
        {
            main[.section, { $0.class = "signage spi" }]
            {
                $0[.p] = """
                This declaration is gated by at least one @_spi attribute.
                """
            }
        }

        let availability:Availability = self.vertex.signature.availability
        if  let renamed:Unidoc.Scalar = self.vertex.renamed,
            let link:HTML.Link<String> = self.context.link(decl: renamed)
        {
            main[.section, { $0.class = "signage deprecation renamed" }]
            {
                $0[.p]
                {
                    $0 += "This declaration has been renamed to "
                    $0 += link
                    $0 += "."
                }
            }
        }
        else if
            let renamed:String = availability.renamed
        {
            main[.section, { $0.class = "signage deprecation renamed" }]
            {
                $0[.p] = "This declaration has been renamed to \(renamed)."
            }
        }

        if  let notice:String = availability.notice
        {
            main[.section, { $0.class = "signage deprecation" }] { $0[.p] = notice }
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

        main[.section, { $0.class = "metadata" }]
        {
            $0[.details]
            {
                $0[.summary] = "Mangled symbol"

                $0[.p, { $0.class = "symbol" }]
                {
                    $0[.code] = self.vertex.symbol.rawValue
                }

                $0[.p]
                {
                    $0[.code]
                    {
                        let hash:FNV24 = .init(hashing: "\(self.vertex.symbol)")
                        $0 += "FNV24: ["
                        $0[.span] { $0.class = "fnv24" } = "\(hash)"
                        $0 += "]"
                    }
                }
            }

            if  let peers:Unidoc.ExtensionGroup = self.groups.peers,
                let list:ConstraintsList = self.context.constraints(peers.constraints)
            {
                $0[.details, { $0.open = true }]
                {
                    $0[.summary] = "Constraints"
                    $0[.code] { $0.class = "constraints" } = list
                }
            }
        }

        main[.section] { $0.class = "details" } =
            (self.vertex.details?.markdown).map(self.context.prose(_:))

        main += self.groups
    }
}
