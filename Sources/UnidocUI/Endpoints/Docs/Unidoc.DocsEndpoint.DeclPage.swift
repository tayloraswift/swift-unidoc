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

extension Unidoc.DocsEndpoint
{
    struct DeclPage
    {
        let sidebar:Unidoc.Sidebar<Unidoc.DocsEndpoint>
        let cone:Unidoc.Cone
        let apex:Unidoc.DeclVertex

        private
        let culture:Unidoc.LinkReference<Unidoc.CultureVertex>
        private
        let colony:Unidoc.LinkReference<Unidoc.CultureVertex>?
        private
        let stem:Unidoc.StemComponents

        init(cone:Unidoc.Cone, apex:Unidoc.DeclVertex, tree:Unidoc.TypeTree?) throws
        {
            self.colony = try apex.colony.map { try cone.context[culture: $0] }
            self.stem = try .init(apex.stem)

            self.cone = cone
            self.apex = apex

            self.culture = try self.cone.context[culture: self.apex.culture]
            self.sidebar = .module(
                volume: self.cone.context.volume,
                origin: self.culture.vertex.module.id,
                tree: tree)
        }
    }
}
extension Unidoc.DocsEndpoint.DeclPage
{
    private
    var demonym:Unidoc.DeclDemonym
    {
        .init(phylum: self.apex.phylum, kinks: self.apex.kinks)
    }
}
extension Unidoc.DocsEndpoint.DeclPage:Unidoc.RenderablePage
{
    var title:String { "\(self.stem.last) · \(self.volume.title) documentation" }

}
extension Unidoc.DocsEndpoint.DeclPage:Unidoc.StaticPage
{
    var location:URI { Unidoc.DocsEndpoint[self.volume, self.apex.route] }
}
extension Unidoc.DocsEndpoint.DeclPage:Unidoc.ApicalPage
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

    func main(_ main:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
    {
        main[.header, { $0.class = "hero" }]
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
                        $0 += " (Default implementation)"
                    }
                }

                $0[.span]
                {
                    $0.class = "domain"
                } = self.context.volume | (self.culture, extends: self.colony)
            }

            $0[.nav]
            {
                $0.class = "breadcrumbs"
            } = Unidoc.LinkVector.init(self.context,
                display: self.stem.scope,
                scalars: self.apex.scope)

            $0[.h1] = self.stem.last
            $0[.div] { $0.class = "docc" } = self.cone.overview

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

        main[.pre, { $0.class = "declaration" }]
        {
            /// See note in `GroupList.Card.swift`.
            let width:Int = "\(self.apex.signature.expanded.bytecode.safe)".count

            $0[.code]
            {
                $0.class = width > 80 ? "multiline" : nil
            } = Unidoc.CodeSection.init(self.context,
                bytecode: self.apex.signature.expanded.bytecode,
                scalars: self.apex.signature.expanded.scalars)
        }

        main[.section, { $0.class = "metadata" }]
        {
            $0[.details]
            {
                $0[.summary] = "Mangled symbol"

                $0[.div, { $0.class = "symbol" }]
                {
                    $0[.code] = self.apex.symbol.rawValue
                    $0 += " "
                    $0[.span, { $0.class = "parenthetical" }]
                    {
                        $0[.a]
                        {
                            $0.href = "/help/what-are-mangled-names"
                        } = "What are these?"
                    }
                }

                $0[.dl]
                {
                    let hash:FNV24 = .init(truncating: .decl(self.apex.symbol))

                    $0[.dt] = "FNV24 hash"
                    $0[.dd] { $0[.code] = "\(hash)" }
                }
            }

            if  let clause:Unidoc.WhereClause = self.cone.halo.peerConstraints | self.context
            {
                $0[.details, { $0.open = true }]
                {
                    $0[.summary] = "Constraints"
                    $0[.div, .code] { $0.class = "constraints" } = clause
                }
            }
        }

        if  case .protocol = self.apex.phylum
        {
            main[.a]
            {
                $0.class = "region"
                $0.href = "\(Unidoc.PtclEndpoint[self.volume, self.apex.route])"
            } = "Browse conforming types"
        }

        main[.div] { $0.class = "docc" } = self.cone.details

        main[.footer] = self.cone.halo
    }
}
