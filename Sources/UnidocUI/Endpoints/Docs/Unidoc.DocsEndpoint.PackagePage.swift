import GitHubAPI
import HTML
import MarkdownRendering
import SemanticVersions
import SHA1
import SymbolGraphs
import Symbols
import Unidoc
import UnidocDB
import UnidocProfiling
import UnidocRecords
import UnixTime
import URI

extension Unidoc.DocsEndpoint
{
    struct PackagePage
    {
        let cone:Unidoc.Cone
        let apex:Unidoc.GlobalVertex

        init(cone:Unidoc.Cone, apex:Unidoc.GlobalVertex)
        {
            self.cone = cone
            self.apex = apex
        }
    }
}
extension Unidoc.DocsEndpoint.PackagePage:Unidoc.RenderablePage
{
    var title:String { "\(self.volume.title) Documentation" }

}
extension Unidoc.DocsEndpoint.PackagePage:Unidoc.StaticPage
{
    var location:URI { Unidoc.DocsEndpoint[self.volume] }
}
extension Unidoc.DocsEndpoint.PackagePage:Unidoc.ApplicationPage
{
    typealias Navigator = HTML.Logo
}
extension Unidoc.DocsEndpoint.PackagePage:Unidoc.ApicalPage
{
    var sidebar:Unidoc.Sidebar<Unidoc.DocsEndpoint>? { .package(volume: self.context.volume) }

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
                            //  FIXME: this could be wrong if the package is renamed.
                            //  We should set this from the repo metadata instead.
                            $0.href = "\(Unidoc.TagsEndpoint[self.volume.symbol.package])"
                        } = "all tags"
                    }
                }
            }

            $0[.h1] = self.title

            if  let repo:Unidoc.PackageRepo = self.context.repo
            {
                $0 += Unidoc.PackageBanner.init(repo: repo,
                    tag: self.volume.refname,
                    now: .now())
            }
        }

        main[.section] { $0.class = "notice canonical" } = self.context.canonical

        main[.section, { $0.class = "details" }]
        {
            if  let repo:Unidoc.PackageRepo = self.context.repo
            {
                $0[.h2] = Heading.repository

                $0[.dl]
                {
                    switch repo.origin
                    {
                    case .github(let origin):
                        $0[.dt] = "Provider"
                        $0[.dd] = "GitHub"

                        if  let license:Unidoc.PackageLicense = repo.license
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
                        if  origin.owner != "apple"
                        {
                            $0[.dt] = "Owner"
                            $0[.dd] = origin.owner
                        }
                    }
                }

                $0[.a]
                {
                    $0.class = "area"
                    $0.href = "\(Unidoc.TagsEndpoint[self.volume.symbol.package])"
                } = "Repo details and more versions"
            }

            if !self.volume.dependencies.isEmpty
            {
                $0[.h2] = Heading.dependencies

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
                        for dependency:Unidoc.VolumeMetadata.Dependency
                            in self.volume.dependencies
                        {
                            $0[.tr]
                            {
                                let pinned:Unidoc.VolumeMetadata?

                                if  let volume:Unidoc.Edition = dependency.pin?.linked,
                                    let volume:Unidoc.VolumeMetadata = self.context[volume]
                                {
                                    //  We link to the tags page here, because we are already
                                    //  linking to the specific version in the other column.
                                    pinned = volume
                                    $0[.td]
                                    {
                                        $0[.a]
                                        {
                                            $0.href = "\(Unidoc.TagsEndpoint[volume.symbol.package])"
                                        } = "\(volume.symbol.package)"
                                    }
                                }
                                else if case _? = dependency.pin
                                {
                                    //  We were able to pin the dependency to a known edition,
                                    //  but we don't have any documentation for it.
                                    //  The volume’s exonym for that package is likely a valid
                                    //  way to access the page for that package, so we will
                                    //  generate a link to that. We know this because the only
                                    //  way the dependency could have been pinned in the first
                                    //  place is if the exonym was a valid alias for the package
                                    //  at some point in the past.
                                    //
                                    //  This isn’t 100% safe, because the exonym may have been
                                    //  deregistered or usurped by another package. But it is
                                    //  useful enough to be worth the 404 errors.
                                    pinned = nil
                                    $0[.td]
                                    {
                                        $0[.a]
                                        {
                                            $0.href = "\(Unidoc.TagsEndpoint[dependency.exonym])"
                                        } = "\(dependency.exonym)"
                                    }
                                }
                                else
                                {
                                    pinned = nil
                                    $0[.td] = "\(dependency.exonym)"
                                }

                                switch dependency.requirement
                                {
                                case nil:                   $0[.td]
                                case .exact(let version)?:  $0[.td] = "\(version)"
                                case .range(let lower, to: let upper)?:    $0[.td]
                                    {
                                        $0 += "\(lower)"
                                        $0[.span] { $0.class = "upto" } = "..<"
                                        $0 += "\(upper)"
                                    }
                                }

                                if  let pinned:Unidoc.VolumeMetadata
                                {
                                    $0[.td]
                                    {
                                        $0[.a]
                                        {
                                            $0.href = "\(Unidoc.DocsEndpoint[pinned])"
                                        } = pinned.symbol.version
                                    }
                                }
                                else if
                                    let version:PatchVersion = dependency.resolution
                                {
                                    $0[.td] = "\(version)"
                                }
                                else
                                {
                                    $0[.td] { $0.class = "placeholder" } = "unstable"
                                }
                            }
                        }
                    }
                }
            }

            $0[.h2] = Heading.platforms

            $0[.dl]
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
                $0[.p, { $0.class = "note" }]
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

                $0[.p] { $0.class = "note" } = """
                Platform requirements originate from the manifest targeting the latest version
                of Swift!
                """
            }

            $0[.h2] = Heading.snapshot

            $0[.dl]
            {
                $0[.dt] = "Symbol Graph ABI"
                $0[.dd] = "\(self.apex.snapshot.abi)"

                if  let commit:SHA1 = self.apex.snapshot.commit
                {
                    $0[.dt] = "Git Revision"
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

                        $0[link: url]
                        {
                            $0.target = "_blank"
                            $0.rel = .external
                            $0.rel = .noopener
                            $0.rel = .google_ugc
                        } = "\(commit)"
                    }
                }
            }

            $0[.div] { $0.class = "more" } = Unidoc.StatsThumbnail.init(
                target: Unidoc.StatsEndpoint[self.volume],
                census: self.apex.snapshot.census,
                domain: self.volume.title,
                title: "Package stats and coverage details")
        }

        main += self.cone.halo
    }
}
