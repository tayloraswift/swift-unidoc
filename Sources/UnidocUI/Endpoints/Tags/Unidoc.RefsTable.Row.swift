import HTML
import Media
import SemanticVersions
import SHA1
import Symbols
import UnidocDB
import UnidocQueries
import UnidocRecords

extension Unidoc.RefsTable
{
    struct Row
    {
        private
        let version:String
        private
        let volume:Unidoc.VolumeMetadata?

        let series:Unidoc.VersionSeries?

        private
        let graph:Graph

        private
        let sha1:SHA1?
        private
        let name:String

        private
        init(version:String,
            volume:Unidoc.VolumeMetadata?,
            series:Unidoc.VersionSeries?,
            graph:Graph,
            sha1:SHA1?,
            name:String)
        {
            self.version = version
            self.volume = volume
            self.series = series
            self.graph = graph
            self.sha1 = sha1
            self.name = name
        }
    }
}
extension Unidoc.RefsTable.Row
{
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

        self.init(version: version.edition.semver?.description ?? version.edition.name,
            volume: version.volume,
            series: series,
            graph: .init(symbol: .init(package: package, ref: version.edition.name),
                state: version.graph.map(Graph.State.some(_:)) ?? .none(version.edition.id),
                view: view),
            //  These might be different for a variety of reasons.
            sha1: version.edition.sha1 ?? version.graph?.commit,
            name: version.edition.name)
    }
}
extension Unidoc.RefsTable.Row:HTML.OutputStreamable
{
    static
    func += (tr:inout HTML.ContentEncoder, self:Self)
    {
        tr[.td]
        {
            $0.class = "ref"
            $0.title = self.name
        } = self.name

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
                } = "\(self.version)"
            }
        }

        tr[.td] { $0.class = "graph" } = self.graph
    }
}
