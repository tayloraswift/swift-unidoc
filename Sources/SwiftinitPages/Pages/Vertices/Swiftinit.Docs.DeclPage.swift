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
        let sidebar:Swiftinit.Sidebar<Swiftinit.Docs>?
        let cone:Unidoc.Cone
        let apex:Unidoc.DeclVertex

        private
        let stem:Unidoc.StemComponents

        init(sidebar:Swiftinit.Sidebar<Swiftinit.Docs>?,
            cone:Unidoc.Cone,
            apex:Unidoc.DeclVertex) throws
        {
            self.sidebar = sidebar
            self.cone = cone
            self.apex = apex

            self.stem = try .init(self.apex.stem)
        }
    }
}
extension Swiftinit.Docs.DeclPage
{
    private
    var demonym:Swiftinit.DeclDemonym
    {
        .init(phylum: self.apex.phylum, kinks: self.apex.kinks)
    }
}
extension Swiftinit.Docs.DeclPage:Swiftinit.RenderablePage
{
    var title:String { "\(self.stem.last) · \(self.volume.title) Documentation" }

}
extension Swiftinit.Docs.DeclPage:Swiftinit.StaticPage
{
    var location:URI { Swiftinit.Docs[self.volume, self.apex.route] }
}
extension Swiftinit.Docs.DeclPage:Swiftinit.ApplicationPage
{
    typealias Navigator = HTML.Logo
}
extension Swiftinit.Docs.DeclPage:Swiftinit.ApicalPage
{
    var descriptionFallback:String
    {
        if  case .swift = self.volume.symbol.package
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

                    if  self.apex.kinks[is: .intrinsicWitness]
                    {
                        $0 += " (Default Implementation)"
                    }
                }

                $0[.span]
                {
                    $0.class = "domain"
                } = self.context.subdomain(self.stem.namespace,
                    namespace: self.apex.namespace,
                    culture: self.apex.culture)
            }

            $0[.nav] { $0.class = "breadcrumbs" } = self.context.vector(self.apex.scope,
                display: self.stem.scope)

            $0[.h1] = self.stem.last

            $0 ?= self.cone.overview

            if  let location:SourceLocation<Unidoc.Scalar> = self.apex.location
            {
                $0 ?= self.context.link(
                    source: location.file,
                    line: location.position.line)
            }
            if  let file:Unidoc.Scalar = self.apex.readme
            {
                $0 ?= self.context.link(source: file)
            }
        }

        if  let _:[String] = self.apex.signature.spis
        {
            main[.section, { $0.class = "signage spi" }]
            {
                $0[.p] = """
                This declaration is gated by at least one @_spi attribute.
                """
            }
        }

        let availability:Availability = self.apex.signature.availability
        if  let renamed:Unidoc.Scalar = self.apex.renamed,
            let link:HTML.Link<UnqualifiedPath> = self.context.link(decl: renamed)
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

        main[.section] { $0.class = "notice canonical" } = self.context.canonical

        main[.section, { $0.class = "declaration" }]
        {
            $0[.pre]
            {
                /// See note in `GroupList.Card.swift`.
                let width:Int = "\(self.apex.signature.expanded.bytecode.safe)".count

                $0[.code]
                {
                    $0.class = width > 80 ? "multiline" : nil
                } = Markdown.CodeSection.init(self.context,
                    bytecode: self.apex.signature.expanded.bytecode,
                    scalars: self.apex.signature.expanded.scalars)
            }
        }

        main[.section, { $0.class = "metadata" }]
        {
            $0[.details]
            {
                $0[.summary] = "Mangled symbol"

                $0[.p, { $0.class = "symbol" }]
                {
                    $0[.code] = self.apex.symbol.rawValue

                    $0[.span, { $0.class = "parenthetical" }]
                    {
                        $0[.a]
                        {
                            $0.href = "/help/what-are-mangled-names"
                        } = "What are these?"
                    }
                }

                $0[.p]
                {
                    $0[.code]
                    {
                        let hash:FNV24 = .init(truncating: .decl(self.apex.symbol))
                        $0 += "FNV24: ["
                        $0[.span] { $0.class = "fnv24" } = "\(hash)"
                        $0 += "]"
                    }
                }
            }

            if  let constraints:Swiftinit.ConstraintsList = .init(self.context,
                    constraints: self.cone.halo.peerConstraints)
            {
                $0[.details, { $0.open = true }]
                {
                    $0[.summary] = "Constraints"
                    $0[.div, .code] { $0.class = "constraints" } = constraints
                }
            }
        }

        main[.section, { $0.class = "details literature" }]
        {
            if  case .protocol = self.apex.phylum
            {
                $0[.a]
                {
                    $0.class = "area"
                    $0.href = "\(Swiftinit.Ptcl[self.volume, self.apex.route])"
                } = "Browse conforming types"
            }

            $0 ?= self.cone.details
        }

        main += self.cone.halo
    }
}
