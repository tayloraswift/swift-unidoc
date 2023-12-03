import GitHubAPI
import HTML
import MarkdownRendering
import SHA1
import SemanticVersions
import SymbolGraphs
import Symbols
import Unidoc
import UnidocDB
import UnidocProfiling
import UnidocRecords
import UnixTime
import URI

extension Site.Docs
{
    struct Package
    {
        let context:IdentifiablePageContext<Unidoc.Scalar>

        let canonical:CanonicalVersion?

        private
        let vertex:Volume.Vertex.Global
        private
        let groups:GroupSections

        init(_ context:IdentifiablePageContext<Unidoc.Scalar>,
            canonical:CanonicalVersion?,
            vertex:Volume.Vertex.Global,
            groups:GroupSections)
        {
            self.context = context
            self.canonical = canonical
            self.vertex = vertex
            self.groups = groups
        }
    }
}
extension Site.Docs.Package
{
    private
    var repo:Realm.Package.Repo? { self.context.repo }
}
extension Site.Docs.Package:RenderablePage
{
    var title:String { "\(self.volume.title) Documentation" }

    var description:String?
    {
        self.volume.symbol.package == .swift ?
        """
        Read the documentation for version \(self.volume.symbol.version) the Swift standard \
        library.
        """ :
        """
        Read the documentation for version \(self.volume.symbol.version) of the \
        \(self.volume.title) package.
        """
    }
}
extension Site.Docs.Package:StaticPage
{
    var location:URI { Site.Docs[self.volume] }
}
extension Site.Docs.Package:ApplicationPage
{
    typealias Navigator = HTML.Logo
}
extension Site.Docs.Package:VersionedPage
{
    var sidebar:HTML.Sidebar<Site.Docs>? { .package(volume: self.context.volume) }

    func main(_ main:inout HTML.ContentEncoder, assets:StaticAssets)
    {
        main[.section]
        {
            $0.class = "introduction"
        }
            content:
        {
            $0[.div, { $0.class = "eyebrows" }]
            {
                $0[.span] { $0.class = "phylum" } = self.volume.symbol.package == .swift
                    ? "Standard Library"
                    : "Package"

                $0[.span, { $0.class = "domain" }]
                {
                    $0[.span] { $0.class = "volume" } = """
                    \(self.volume.symbol.package) \(self.volume.symbol.version)
                    """

                    $0[.span, { $0.class = "jump" }]
                    {
                        $0[.a]
                        {
                            $0.href = "\(Site.Tags[self.volume.symbol.package])"
                        } = "all tags"
                    }
                }
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
            if  let repo:Realm.Package.Repo = self.repo
            {
                let heading:AutomaticHeading = .packageRepository
                $0[.h2] { $0.id = heading.id } = heading

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

                        //  If the repo belongs to a person, show the owner.
                        if  repo.owner.login != "apple"
                        {
                            $0[.dt] = "Owner"
                            $0[.dd] = repo.owner
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

            if !self.volume.dependencies.isEmpty
            {
                let heading:AutomaticHeading = .packageDependencies
                $0[.h2] { $0.id = heading.id } = heading

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
                        for dependency:Volume.Metadata.Dependency in self.volume.dependencies
                        {
                            $0[.tr]
                            {
                                let pinned:Volume.Metadata?

                                if  let pin:Unidoc.Edition = dependency.pinned
                                {
                                    pinned = self.context.volumes[pin]

                                    $0[.td]
                                    {
                                        let symbol:Symbol.Package = pinned?.symbol.package
                                            ?? dependency.symbol

                                        $0[.a]
                                        {
                                            $0.href = "\(Site.Tags[symbol])"
                                        } = "\(symbol)"
                                    }
                                }
                                else
                                {
                                    pinned = nil

                                    $0[.td] = "\(dependency.symbol)"
                                }

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

                                if  let pinned:Volume.Metadata
                                {
                                    $0[.td]
                                    {
                                        $0[.a]
                                        {
                                            $0.href = "\(Site.Docs[pinned])"
                                        } = pinned.symbol.version
                                    }
                                }
                                else if
                                    let version:PatchVersion = dependency.resolution
                                {
                                    $0[.td] = "\(version) (unavailable)"
                                }
                                else
                                {
                                    $0[.td]
                                }
                            }
                        }
                    }
                }
            }

            do
            {
                let heading:AutomaticHeading = .platformRequirements
                $0[.h2] { $0.id = heading.id } = heading
            }

            $0[.table, { $0.class = "platforms" }]
            {
                $0[.thead]
                {
                    $0[.tr]
                    {
                        $0[.th] = "Platform"
                        $0[.th] = "Minimum Version"
                    }
                }
                $0[.tbody]
                {
                    //  Every package on Swiftinit supports Linux.
                    $0[.tr]
                    {
                        $0[.td] = "linux"
                        $0[.td] = "none"
                    }
                    for platform:SymbolGraphMetadata.PlatformRequirement in
                        self.vertex.snapshot.requirements
                    {
                        $0[.tr]
                        {
                            $0[.td] = "\(platform.id)"
                            $0[.td] = "\(platform.min)"
                        }
                    }
                }
            }

            do
            {
                let heading:AutomaticHeading = .snapshotInformation
                $0[.h2] { $0.id = heading.id } = heading
            }

            $0[.dl]
            {
                $0[.dt] = "Symbol Graph ABI"
                $0[.dd] = "\(self.vertex.snapshot.abi)"

                if  let commit:SHA1 = self.volume.commit
                {
                    $0[.dt] = "Git Revision"
                    $0[.dd]
                    {
                        let url:String?
                        if  case .github(let path)? = self.repo?.origin
                        {
                            url = "https://github.com\(path)/tree/\(commit)"
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
                        } = "\(commit)"
                    }
                }
            }


            $0[.div, { $0.class = "more" }]
            {
                let url:String = "\(Site.Stats[self.volume])"

                $0[.div, { $0.class = "charts" }]
                {
                    $0[.div]
                    {
                        $0[.p]
                        {
                            let target:AutomaticHeading = .interfaceBreakdown
                            $0[.a] { $0.href = "\(url)#\(target.id)" } = "Declarations"
                        }

                        $0[.figure]
                        {
                            $0.class = "chart decl"
                        } = self.vertex.snapshot.census.unweighted.decls.pie
                        {
                            """
                            \($1) percent of the declarations in \
                            \(self.volume.title) are \($0.name)
                            """
                        }
                    }
                    $0[.div]
                    {
                        let target:AutomaticHeading = .documentationCoverage
                        $0[.p]
                        {
                            $0[.a] { $0.href = "\(url)#\(target.id)" } = "Coverage"
                        }

                        $0[.figure]
                        {
                            $0.class = "chart coverage"
                        } = self.vertex.snapshot.census.unweighted.coverage.pie
                        {
                            """
                            \($1) percent of the declarations in \
                            \(self.volume.title) are \($0.name)
                            """
                        }
                    }
                }

                $0[.a] { $0.href = url } = "Package stats and coverage details"
            }
        }

        main += self.groups
    }
}
