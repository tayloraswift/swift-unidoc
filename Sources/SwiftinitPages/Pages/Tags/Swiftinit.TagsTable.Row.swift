import HTML
import Media
import SemanticVersions
import SHA1
import Symbols
import UnidocDB
import UnidocQueries
import UnidocRecords

extension Swiftinit.TagsTable
{
    struct Row
    {
        let volume:Unidoc.VolumeMetadata?
        let tagged:Tagged?
        let graph:GraphCell?

        private
        init(volume:Unidoc.VolumeMetadata?, tagged:Tagged?, graph:GraphCell?)
        {
            self.volume = volume
            self.tagged = tagged
            self.graph = graph
        }
    }
}
extension Swiftinit.TagsTable.Row
{
    init(
        volume:Unidoc.VolumeMetadata?,
        tagged:Tagged?,
        package:Symbol.Package,
        graph:Unidoc.VersionsQuery.Graph?,
        view:Swiftinit.ViewMode)
    {
        self.init(
            volume: volume,
            tagged: tagged,
            graph: graph.map { .init(package: package, graph: $0, view: view) })
    }
}
extension Swiftinit.TagsTable.Row:HTML.OutputStreamable
{
    static
    func += (tr:inout HTML.ContentEncoder, self:Self)
    {
        let version:PatchVersion
        let release:Bool?

        if  let tag:Tagged = self.tagged
        {
            let sha1:String? = tag.commit?.description
            tr[.td] { $0.class = "refname" } = tag.name
            tr[.td]
            {
                $0.class = "commit"
                $0.title = sha1

            } = sha1?.prefix(7) ?? ""

            version = tag.version
            release = tag.release
        }
        else
        {
            tr[.td]
            tr[.td]

            version = .v(0, 0, 0)
            release = nil
        }

        tr[.td, { $0.class = "version" }]
        {
            if  let volume:Unidoc.VolumeMetadata = self.volume
            {
                $0[.a] { $0.href = "\(Swiftinit.Docs[volume])" } = "\(version)"
            }
            else
            {
                $0[.span]
                {
                    $0.title = "No documentation has been generated for this version."
                } = "\(version)"

                return
            }

            switch release
            {
            case true?:
                break

            case false?:
                $0 += " "
                $0[.span]
                {
                    $0.class = "parenthetical"
                    $0.title = "This documentation is a prerelease version."
                } = "prerelease"

            case nil:
                $0 += " "
                $0[.span]
                {
                    $0.class = "parenthetical"
                    $0.title = "This documentation is unversioned."
                } = "unversioned"
            }
        }

        if  let cell:Swiftinit.TagsTable.GraphCell = self.graph
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
