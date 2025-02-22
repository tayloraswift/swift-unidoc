import GitHubAPI
import HTML
import MarkdownRendering
import PieCharts
import SemanticVersions
import SHA1
import SymbolGraphs
import Symbols
import Unidoc
import UnidocDB
import UnidocRecords
import UnixCalendar
import UnixTime
import URI

extension Unidoc.DocsEndpoint
{
    struct PackagePage
    {
        let cone:Unidoc.Cone
        let apex:Unidoc.LandingVertex

        init(cone:Unidoc.Cone, apex:Unidoc.LandingVertex)
        {
            self.cone = cone
            self.apex = apex
        }
    }
}
extension Unidoc.DocsEndpoint.PackagePage
{
    /// This might be different from the volume symbol if the package has been renamed.
    private
    var tags:Symbol.Package
    {
        self.context.packages.principal?.symbol ?? self.volume.symbol.package
    }
}
extension Unidoc.DocsEndpoint.PackagePage:Unidoc.RenderablePage
{
    var title:String { "\(self.volume.title) documentation" }

}
extension Unidoc.DocsEndpoint.PackagePage:Unidoc.StaticPage
{
    var location:URI { Unidoc.DocsEndpoint[self.volume] }
}
extension Unidoc.DocsEndpoint.PackagePage:Unidoc.ApicalPage
{
    var sidebar:Unidoc.Sidebar<Unidoc.DocsEndpoint> { .package(volume: self.context.volume) }

    var descriptionFallback:String
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

    func main(_ main:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
    {
        let tags:URI = Unidoc.RefsEndpoint[self.tags]

        main[.header, { $0.class = "hero" }]
        {
            $0[.div, { $0.class = "eyebrows" }]
            {
                $0[.span] { $0.class = "phylum" } = self.volume.symbol.package == .swift
                    ? "Standard library"
                    : "Package"

                $0[.span, { $0.class = "domain" }]
                {
                    $0[.span] { $0.class = "volume" } = """
                    \(self.volume.symbol.package) \(self.volume.symbol.version)
                    """

                    $0[.span, { $0.class = "jump" }]
                    {
                        $0[.a] { $0.href = "\(tags)" } = "all tags"
                    }
                }
            }

            $0[.h1] = self.title

            guard
            let repo:Unidoc.PackageRepo = self.context.repo
            else
            {
                return
            }

            $0[.p] = repo.origin.about
            $0[.div]
            {
                $0.class = "chyron"
            } = repo.chyron(now: format.time, ref: self.volume.commit?.name)
        }

        main[.section] { $0.class = "notice canonical" } = self.context.canonical

        if  let repo:Unidoc.PackageRepo = self.context.repo
        {
            main[.h2] = Heading.repository
            main[.dl] = Unidoc.PackageRepoDescriptionList.init(repo: repo, mode: .abridged)

            main[.a]
            {
                $0.class = "region"
                $0.href = "\(tags)"
            } = "Repo details and more versions"
        }

        //  Every package should have at least one dependency, the standard library, except for
        //  the standard library itself.
        if !self.volume.dependencies.isEmpty
        {
            main[.h2] = Heading.dependencies
            main[.table]
            {
                $0.class = "dependencies"
            } = Unidoc.DependencyTable.init(
                dependencies: self.volume.dependencies,
                context: self.context)
        }

        if  self.volume.symbol.package != .swift,
            !(self.volume.dependencies.contains { $0.exonym == .swift })
        {
            main[.section, { $0.class = "signage deprecation" }]
            {
                $0[.p] = """
                This symbol graph was not linked against the Swift standard library! \
                Check that you have correctly initialized the database with at least one copy \
                of a standard library generated from the same or a newer version of Swift as \
                was used to build this symbol graph.
                """
            }
        }

        main[.h2] = Heading.platforms

        main[.dl]
        {
            //  $0[.dt] = "Supports Linux?"
            //  $0[.dd] = "yes"

            if  let version:PatchVersion = self.apex.snapshot.latestManifest
            {
                $0[.dt] = "Swift tools version"
                $0[.dd] = "\(version)"
            }
        }

        if !self.apex.snapshot.extraManifests.isEmpty
        {
            main[.p, { $0.class = "note" }]
            {
                $0 += "This package vends additional manifests targeting specific versions "
                $0[.em] = """
                (\(self.apex.snapshot.extraManifests.map
                {
                    "\($0)"
                }.joined(separator: ", ")))
                """
                $0 += " of Swift!"
            }
        }
        if !self.apex.snapshot.requirements.isEmpty
        {
            main[.table, { $0[data: "type"] = "platforms" }]
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
                    for platform:SymbolGraphMetadata.PlatformRequirement in
                        self.apex.snapshot.requirements
                    {
                        $0[.tr]
                        {
                            $0[.td] = "\(platform.id)"
                            $0[.td] = "\(platform.min)"
                        }
                    }
                }
            }

            main[.p] { $0.class = "note" } = """
            Platform requirements originate from the manifest targeting the latest version
            of Swift!
            """
        }

        main[.h2] = Heading.linkage

        main[.dl]
        {
            $0[.dt] = "Symbol graph ABI"
            $0[.dd] = "\(self.apex.snapshot.abi)"

            if  let symbolsLinkable:Int = self.apex.snapshot.symbolsLinkable,
                let symbolsLinked:Int = self.apex.snapshot.symbolsLinked
            {
                $0[.dt] = "Symbols linked"
                $0[.dd]
                {
                    let percentage:Int = symbolsLinkable != 0
                        ? symbolsLinked * 100 / symbolsLinkable
                        : 100

                    $0[.span] = "\(symbolsLinked) / \(symbolsLinkable)"
                    $0 += " "
                    $0[.span]
                    {
                        $0.class = percentage < 100
                            ? "parenthetical warn"
                            : "parenthetical"
                    } = "\(percentage)%"
                }
            }

            //  TODO: we shouldn’t need the SnapshotDetails for this, after uplinking all
            //  the volume metadata.
            if  let commit:SHA1 = self.volume.commit?.sha1 ?? self.apex.snapshot.commit
            {
                $0[.dt] = "Git revision"
                $0[.dd]
                {
                    let url:String?
                    if  case .github(let origin)? = self.context.repo?.origin
                    {
                        url = "\(origin.https)/tree/\(commit)"
                    }
                    else
                    {
                        url = nil
                    }

                    $0[link: url] { $0.external(safe: false) } = "\(commit)"
                }
            }
            if  let date:UnixMillisecond = self.volume.commit?.date,
                let date:Timestamp = date.timestamp
            {
                $0[.dt] = "Git commit date"
                $0[.dd] = "\(date.http)"
            }
        }

        main[.div] { $0.class = "more" } = Unidoc.StatsThumbnail.init(
            target: Unidoc.StatsEndpoint[self.volume],
            census: self.apex.snapshot.census,
            domain: self.volume.title,
            title: "Package stats and coverage details")

        main[.footer] = self.cone.halo
    }
}
