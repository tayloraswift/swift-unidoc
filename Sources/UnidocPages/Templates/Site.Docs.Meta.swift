import GitHubAPI
import HTML
import MarkdownRendering
import ModuleGraphs
import SHA1
import Unidoc
import UnidocDB
import UnidocRecords
import UnixTime
import URI

extension Site.Docs
{
    struct Meta
    {
        let inliner:Inliner

        let canonical:CanonicalVersion?
        private
        let master:Volume.Vertex.Meta
        private
        let groups:[Volume.Group]

        init(_ inliner:Inliner,
            canonical:CanonicalVersion?,
            master:Volume.Vertex.Meta,
            groups:[Volume.Group])
        {
            self.inliner = inliner
            self.canonical = canonical
            self.master = master
            self.groups = groups
        }
    }
}
extension Site.Docs.Meta
{
    private
    var repo:PackageRepo? { self.inliner.repo }
}
extension Site.Docs.Meta:RenderablePage
{
    var title:String { self.volume.title }

    var description:String?
    {
        self.volume.symbol.package == .swift ?
        """
        Read the documentation for version \(self.volume.symbol.version) the Swift standard \
        library.
        """ :
        """
        Read the documentation for version \(self.volume.symbol.version) of the \
        \(self.volume.display ?? "\(self.volume.symbol.package)") package.
        """
    }
}
extension Site.Docs.Meta:StaticPage
{
    var location:URI { Site.Docs[self.volume] }
}
extension Site.Docs.Meta:ApplicationPage
{
    typealias Navigator = HTML.Logo
}
extension Site.Docs.Meta:VersionedPage
{
    typealias Sidebar = Never

    var volume:Volume.Meta { self.inliner.volumes.principal }

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
                $0[.span] { $0.class = "phylum" } = self.volume.symbol.package == .swift ?
                    "Standard Library" :
                    "Package"

                $0[.span, { $0.class = "domain" }] = self.volume.symbol.version
            }

            $0[.h1] = self.title

            switch self.repo
            {
            case .github(let repo)?:
                $0[.p] = repo.about

            case nil:
                break
            }
            if  let refname:String = self.volume.refname
            {
                switch self.repo?.origin
                {
                case .github(let path)?:
                    $0 += HTML.SourceLink.init(file: path.dropFirst(),
                        target: "https://github.com\(path)/tree/\(refname)")

                case nil:
                    break
                }
            }
        }

        main[.section] { $0.class = "notice canonical" } = self.canonical

        main[.section, { $0.class = "details" }]
        {
            if  let repo:PackageRepo = self.repo
            {
                $0[.h2] = "Package Repository"

                $0[.dl]
                {
                    switch repo
                    {
                    case .github(let repo):
                        $0[.dt] = "Provider"
                        $0[.dd] = "GitHub"

                        if  let license:GitHub.Repo.License = repo.license
                        {
                            $0[.dt] = "License"
                            $0[.dd] = license.name
                        }

                        if !repo.topics.isEmpty
                        {
                            $0[.dt] = "Keywords"
                            $0[.dd] = repo.topics.joined(separator: ", ")
                        }
                    }
                }

                $0[.div, { $0.class = "more" }]
                {
                    $0[.a]
                    {
                        $0.href = "\(Site.Tags[self.volume.symbol.package])"
                    } = "Repo details and more versions"
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
                        for dependency:Volume.Vertex.Meta.Dependency in self.master.dependencies
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
                                    let pin:Volume.Meta = self.inliner.volumes[pin]
                                {
                                    $0[.td]
                                    {
                                        $0[.a]
                                        {
                                            $0.href = "\(Site.Docs[pin])"
                                        } = pin.symbol.version
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
                        if  case .github(let path)? = self.repo?.origin
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
