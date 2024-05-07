import HTML
import Media
import SemanticVersions
import SHA1
import Symbols
import UnidocDB
import UnidocQueries
import UnidocRecords

extension Unidoc.TagsTable
{
    struct Row
    {
        let volume:Unidoc.VolumeMetadata?
        let series:Unidoc.VersionSeries?
        let patch:PatchVersion?

        let graph:GraphCell?

        let sha1:SHA1?
        let name:String

        private
        init(volume:Unidoc.VolumeMetadata?,
            series:Unidoc.VersionSeries?,
            patch:PatchVersion?,
            graph:GraphCell?,
            sha1:SHA1?,
            name:String)
        {
            self.volume = volume
            self.series = series
            self.patch = patch
            self.graph = graph
            self.sha1 = sha1
            self.name = name
        }
    }
}
extension Unidoc.TagsTable.Row
{
    init(package:Symbol.Package,
        version:Unidoc.Versions.TopOfTree,
        view:Unidoc.Permissions)
    {
        self.init(
            volume: version.volume,
            series: nil,
            patch: nil,
            graph: version.graph.map { .init(package: package, graph: $0, view: view) },
            sha1: nil,
            name: "")
    }

    init(package:Symbol.Package,
        version:Unidoc.VersionState,
        view:Unidoc.Permissions)
    {
        let series:Unidoc.VersionSeries?
        if  case _? = version.edition.semver
        {
            series = version.edition.release ? .release : .prerelease
        }
        else
        {
            series = nil
        }

        self.init(
            volume: version.volume,
            series: series,
            patch: version.edition.semver,
            graph: version.graph.map { .init(package: package, graph: $0, view: view) },
            sha1: version.edition.sha1,
            name: version.edition.name)
    }
}
extension Unidoc.TagsTable.Row:HTML.OutputStreamable
{
    static
    func += (tr:inout HTML.ContentEncoder, self:Self)
    {
        tr[.td] { $0.class = "refname" } = self.name

        let sha1:String? = self.sha1?.description

        tr[.td]
        {
            $0.class = "commit"
            $0.title = sha1

        } = sha1?.prefix(7) ?? ""

        tr[.td, { $0.class = "version" }]
        {
            if  let volume:Unidoc.VolumeMetadata = self.volume
            {
                $0[.a] { $0.href = "\(Unidoc.DocsEndpoint[volume])" } = volume.symbol.version
            }
            else
            {
                $0[.span]
                {
                    $0.title = "No documentation has been generated for this version."
                } = "\(self.patch?.description ?? self.name)"

                return
            }

            switch self.series
            {
            case nil:
                $0 += " "
                $0[.span]
                {
                    $0.class = "parenthetical"
                    $0.title = "This documentation is unversioned."
                } = "unversioned"

            case .prerelease?:
                $0 += " "
                $0[.span]
                {
                    $0.class = "parenthetical"
                    $0.title = "This documentation is a prerelease version."
                } = "prerelease"

            case .release?:
                break
            }
        }

        if  let cell:Unidoc.TagsTable.GraphCell = self.graph
        {
            tr[.td] { $0.class = "graph" } = cell
        }
        else
        {
            tr[.td, { $0.class = "graph" }]
            {
                $0[.span]
                {
                    $0.title = "No symbol graph has been built for this version."
                }
            }
        }
    }
}
