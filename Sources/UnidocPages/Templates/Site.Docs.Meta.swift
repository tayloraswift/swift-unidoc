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

            var breakdown:(unweighted:Pie, weighted:Pie) = ([], [])
            for (value, `class`, what):
                (KeyPath<Record.Master.Meta.Stats.Decl, Int>, String, String) in
            [
                (
                    \.functions,
                    "function",
                    "free functions or variables"
                ),
                (
                    \.operators,
                    "operator",
                    "operators"
                ),
                (
                    \.constructors,
                    "constructor",
                    "initializers, type members, or enum cases"
                ),
                (
                    \.methods,
                    "method",
                    "instance methods"
                ),
                (
                    \.subscripts,
                    "subscript",
                    "instance subscripts"
                ),
                (
                    \.functors,
                    "functor",
                    "functors"
                ),
                (
                    \.protocols,
                    "protocol",
                    "protocols"
                ),
                (
                    \.requirements,
                    "requirement",
                    "protocol requirements"
                ),
                (
                    \.witnesses,
                    "witness",
                    "default implementations"
                ),
                (
                    \.actors,
                    "actor",
                    "actors"
                ),
                (
                    \.classes,
                    "class",
                    "classes"
                ),
                (
                    \.structures,
                    "structure",
                    "structs or enums"
                ),
                (
                    \.typealiases,
                    "typealias",
                    "typealiases"
                ),
            ]
            {
                @Sendable
                func percent(_ value:Double) -> String
                {
                    let permille:Int = .init((value * 1000).rounded())
                    let (percent, f):(Int, Int) = permille.quotientAndRemainder(
                        dividingBy: 10)

                    return "\(percent).\(f) percent"
                }

                let unweighted:Int = self.master.stats.decls[keyPath: value]
                let weighted:Int = unweighted +
                    self.master.stats.firstPartyFeatures[keyPath: value] +
                    self.master.stats.thirdPartyFeatures[keyPath: value]

                if  unweighted > 0
                {
                    let value:Pie.Value = .init(weight: unweighted,
                        class: `class`)
                    {
                        return """
                        \(percent($0)) of the declarations in this package are \(what)
                        """
                    }
                    breakdown.unweighted.values.append(value)
                }
                if  weighted > 0
                {
                    let value:Pie.Value = .init(weight: weighted,
                        class: `class`)
                    {
                        return """
                        \(percent($0)) of the symbols in this package are \(what)
                        """
                    }
                    breakdown.weighted.values.append(value)
                }
            }

            $0[.h2] = "Symbol Breakdown"

            $0[.h3] = "Symbols"

            $0 += breakdown.weighted

            $0[.h3] = "Declarations"

            $0 += breakdown.unweighted

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
