import HTML
import MarkdownRendering
import ModuleGraphs
import UnidocRecords
import Unidoc
import URI

extension Site.Docs
{
    struct Meta
    {
        let inliner:Inliner

        private
        let master:Record.Master.Meta
        private
        let groups:[Record.Group]

        init(_ inliner:Inliner,
            master:Record.Master.Meta,
            groups:[Record.Group])
        {
            self.inliner = inliner
            self.master = master
            self.groups = groups
        }
    }
}
extension Site.Docs.Meta
{
    private
    var zone:Record.Zone { self.inliner.zones.principal }
}
extension Site.Docs.Meta:FixedPage
{
    var location:URI { Site.Docs[self.zone] }
    var title:String { self.zone.title }
}
extension Site.Docs.Meta:ApplicationPage
{
    typealias Navigator = HTML.Logo
    typealias Sidebar = Never

    var search:URI
    {
        Site.NounMaps[self.zone]
    }

    func main(_ main:inout HTML.ContentEncoder)
    {
        let groups:Inliner.Groups = .init(inliner,
            groups: self.groups,
            bias: self.master.id,
            mode: .meta)

        main[.section]
        {
            $0.class = "introduction"
        }
        content:
        {
            $0[.div, { $0.class = "eyebrows" }]
            {
                $0[.span] { $0.class = "phylum" } = self.zone.package == .swift ?
                    "Standard Library" :
                    "Package"

                $0[.span, { $0.class = "domain" }]
                {
                    $0[.span] { $0.class = "version" } = self.zone.version
                }
            }

            $0[.h1] = self.title

            if  let refname:String = self.zone.refname,
                let github:String = self.zone.github,
                let slash:String.Index = github.firstIndex(of: "/")
            {
                $0 += HTML.SourceLink.init(
                    file: github[github.index(after: slash)...],
                    target: "https://\(github)/tree/\(refname)")
            }
        }

        main[.section]
        {
            $0.class = "details"
        }
        content:
        {
            if !self.master.platforms.isEmpty
            {
                $0[.h2] = "Platform Requirements"

                $0[.dl]
                {
                    for platform:PlatformRequirement in self.master.platforms
                    {
                        $0[.dt] = "\(platform.id)"
                        $0[.dd] = "\(platform.min)"
                    }
                }
            }

            if !self.master.dependencies.isEmpty
            {
                $0[.h2] = "Package Dependencies"

                $0[.table, { $0.class = "dependencies" }]
                {
                    $0[.thead]
                    {
                        $0[.tr]
                        {
                            $0[.th] = "Package"
                            $0[.th] = "Requirement"
                            $0[.th] = "Resolved Version"
                        }
                    }
                    $0[.tbody]
                    {
                        for dependency:Record.Master.Meta.Dependency in self.master.dependencies
                        {
                            $0[.tr]
                            {
                                $0[.td] = "\(dependency.id)"

                                switch dependency.requirement
                                {
                                case nil:                   $0[.td]
                                case .exact(let version)?:  $0[.td] = "\(version)"
                                case .range(let range)?:    $0[.td]
                                    {
                                        $0 += "\(range.lowerBound)"
                                        $0[.span] { $0.class = "upto" } = "..<"
                                        $0 += "\(range.upperBound)"
                                    }
                                }

                                if  let pin:Unidoc.Zone = dependency.resolution,
                                    let pin:Record.Zone = self.inliner.zones[pin]
                                {
                                    $0[.td]
                                    {
                                        $0[.a] { $0.href = "\(Site.Docs[pin])" } = pin.version
                                    }
                                }
                                else
                                {
                                    $0[.td] = "unavailable"
                                }
                            }
                        }
                    }
                }
            }

            var breakdown:
            (
                unweighted:Pie<HTML.Stats.DeclPhylum>,
                weighted:Pie<HTML.Stats.DeclPhylum>
            ) = ([], [])

            for category:KeyPath<Record.Stats.Decl, Int> in
            [
                \.functions,
                \.operators,
                \.constructors,
                \.methods,
                \.subscripts,
                \.functors,
                \.protocols,
                \.requirements,
                \.witnesses,
                \.actors,
                \.classes,
                \.structures,
                \.typealiases,
            ]
            {
                let unweighted:Int = self.master.census.unweighted.decls[keyPath: category]
                if  unweighted > 0
                {
                    breakdown.unweighted.values.append(.init(category,
                        domain: "declarations in this package",
                        weight: unweighted))
                }

                let weighted:Int = self.master.census.weighted.decls[keyPath: category]
                if  weighted > 0
                {
                    breakdown.weighted.values.append(.init(category,
                        domain: "symbols in this package",
                        weight: weighted))
                }
            }

            $0[.h2] = "Symbol Breakdown"

            $0[.h3] = "Symbols"

            $0 += breakdown.weighted

            $0[.h3] = "Declarations"

            $0 += breakdown.unweighted

            var coverage:
            (
                unweighted:Pie<HTML.Stats.Coverage>,
                weighted:Pie<HTML.Stats.Coverage>
            ) = ([], [])

            for category:KeyPath<Record.Stats.Coverage, Int> in
            [
                \.direct,
                \.indirect,
                \.undocumented,
            ]
            {
                let unweighted:Int = self.master.census.unweighted.coverage[keyPath: category]
                if  unweighted > 0
                {
                    coverage.unweighted.values.append(.init(category,
                        domain: "declarations in this package",
                        weight: unweighted))
                }

                let weighted:Int = self.master.census.weighted.coverage[keyPath: category]
                if  weighted > 0
                {
                    coverage.weighted.values.append(.init(category,
                        domain: "symbols in this package",
                        weight: weighted))
                }
            }

            $0[.h2] = "Documentation Coverage"

            $0[.h3] = "Symbols"

            $0 += coverage.weighted

            $0[.h3] = "Declarations"

            $0 += coverage.unweighted

            $0[.h2] = "Snapshot Information"

            $0[.dl]
            {
                $0[.dt] = "Symbol Graph ABI"
                $0[.dd] = "\(self.master.abi)"

                if  let revision:Repository.Revision = self.master.revision
                {
                    $0[.dt] = "Git Revision"
                    $0[.dd]
                    {
                        $0[link: self.zone.github.map { "https://\($0)/tree/\(revision)" }]
                        {
                            $0.rel = .noopener
                            $0.rel = .google_ugc
                            $0.target = "_blank"
                        } = "\(revision)"
                    }
                }
            }
        }

        main += groups
    }
}
