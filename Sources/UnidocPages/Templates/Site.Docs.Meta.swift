import HTML
import MarkdownRendering
import ModuleGraphs
import SHA1
import UnidocRecords
import Unidoc
import URI

extension Site.Docs
{
    struct Meta
    {
        let inliner:Inliner

        private
        let master:Volume.Master.Meta
        private
        let groups:[Volume.Group]

        init(_ inliner:Inliner,
            master:Volume.Master.Meta,
            groups:[Volume.Group])
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
    var names:Volume.Names { self.inliner.names.principal }
}
extension Site.Docs.Meta:FixedPage
{
    var location:URI { Site.Docs[self.names] }
    var title:String { self.names.title }
}
extension Site.Docs.Meta:ApplicationPage
{
    typealias Navigator = HTML.Logo
    typealias Sidebar = Never

    var volume:VolumeIdentifier { self.names.volume }

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
                $0[.span] { $0.class = "phylum" } = self.names.package == .swift ?
                    "Standard Library" :
                    "Package"

                $0[.span, { $0.class = "domain" }]
                {
                    $0[.span] { $0.class = "version" } = self.names.version
                }
            }

            $0[.h1] = self.title

            if  case .github(let path)? = self.names.origin,
                let refname:String = self.names.refname
            {
                $0 += HTML.SourceLink.init(file: path.dropFirst(),
                    target: "https://github.com\(path)/tree/\(refname)")
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
                        for dependency:Volume.Master.Meta.Dependency in self.master.dependencies
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
                                    let pin:Volume.Names = self.inliner.names[pin]
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

            $0[.h2] = "Interface Breakdown"

            $0 += Unidoc.StatsBreakdown.init(
                unweighted: self.master.census.unweighted.decls,
                weighted: self.master.census.weighted.decls,
                domain: "this package")


            $0[.h2] = "Documentation Coverage"

            $0 += Unidoc.StatsBreakdown.init(
                unweighted: self.master.census.unweighted.coverage,
                weighted: self.master.census.weighted.coverage,
                domain: "this package")


            $0[.h2] = "Snapshot Information"

            $0[.dl]
            {
                $0[.dt] = "Symbol Graph ABI"
                $0[.dd] = "\(self.master.abi)"

                if  let revision:SHA1 = self.master.revision
                {
                    $0[.dt] = "Git Revision"
                    $0[.dd]
                    {
                        let url:String?
                        if  case .github(let path)? = self.names.origin
                        {
                            url = "https://github.com\(path)/tree/\(revision)"
                        }
                        else
                        {
                            url = nil
                        }

                        $0[link: url]
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
