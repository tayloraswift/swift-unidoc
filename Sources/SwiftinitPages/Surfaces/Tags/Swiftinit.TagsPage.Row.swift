import HTML
import Media
import SemanticVersions
import SHA1
import Symbols
import UnidocDB
import UnidocQueries
import UnidocRecords

extension Swiftinit.TagsPage
{
    struct Row
    {
        let linkable:UplinkButton?

        let volume:Unidoc.VolumeMetadata?
        let graph:Unidoc.VersionsQuery.Graph?
        let type:RowType

        private
        init(linkable:UplinkButton?,
            volume:Unidoc.VolumeMetadata?,
            graph:Unidoc.VersionsQuery.Graph?,
            type:RowType)
        {
            self.linkable = linkable
            self.volume = volume
            self.graph = graph
            self.type = type
        }
    }
}
extension Swiftinit.TagsPage.Row
{
    init(maintainer:Bool,
        package:Symbol.Package,
        volume:Unidoc.VolumeMetadata?,
        graph:Unidoc.VersionsQuery.Graph?,
        type:Swiftinit.TagsPage.RowType)
    {
        self.init(linkable: maintainer
                ? graph.map { .init(edition: $0.id, package: package) }
                : nil,
            volume: volume,
            graph: graph,
            type: type)
    }
}
extension Swiftinit.TagsPage.Row:HTML.OutputStreamable
{
    static
    func += (tr:inout HTML.ContentEncoder, self:Self)
    {
        let version:PatchVersion

        switch self.type
        {
        case .tagged(let name, let commit, let docs, release: _):
            let sha1:String? = commit?.description
            tr[.td] { $0.class = "refname" } = name
            tr[.td]
            {
                $0.class = "commit"
                $0.title = sha1

            } = sha1?.prefix(7) ?? ""

            version = docs

        case .tagless:
            tr[.td]
            tr[.td]

            version = .v(0, 0, 0)
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

            switch self.type
            {
            case .tagged(_, _, _, release: true):
                break

            case .tagged(_, _, _, release: false):
                $0 += " "
                $0[.span]
                {
                    $0.class = "parenthetical"
                    $0.title = "This documentation is a prerelease version."
                } = "prerelease"

            case .tagless:
                $0 += " "
                $0[.span]
                {
                    $0.class = "parenthetical"
                    $0.title = "This documentation is unversioned."
                } = "unversioned"
            }
        }
        tr[.td, { $0.class = "graph" }]
        {
            if  let graph:Unidoc.VersionsQuery.Graph = self.graph
            {
                let size:Int = graph.inlineBytes ?? graph.remoteBytes

                $0[.span]
                {
                    $0.class = graph.link != nil ? "abi uplinking" : "abi"
                    $0.title = graph.link != nil ? """
                        This symbol graph is currently queued for documentation generation.
                        """ : nil
                } = "\(graph.abi)"

                $0 += " "

                $0[.span]
                {
                    $0.class = "kb"
                    $0.title = "\(size) bytes, \(graph.inlineBytes ?? 0) bytes on disk"

                } = "(\(size >> 10) kb)"
            }
            else
            {
                $0[.span]
                {
                    $0.title = "No symbol graph has been built for this version."
                }
            }

            if  let button:Swiftinit.TagsPage.UplinkButton = self.linkable
            {
                $0[.form]
                {
                    $0.enctype = "\(MediaType.application(.x_www_form_urlencoded))"
                    $0.action = "\(Swiftinit.API[.uplink])"
                    $0.method = "post"
                } = button
            }
        }
    }
}
