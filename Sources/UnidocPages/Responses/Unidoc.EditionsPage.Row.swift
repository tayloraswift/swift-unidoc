import HTML
import SemanticVersions
import UnidocDB
import UnidocQueries
import UnidocRecords

extension Unidoc.EditionsPage
{
    struct Row
    {
        let name:String
        let sha1:String?
        let release:Bool
        let version:PatchVersion
        let volume:Unidoc.VolumeMetadata?
        let graph:Unidoc.EditionOutput.Graph?
    }
}
extension Unidoc.EditionsPage.Row:HyperTextOutputStreamable
{
    static
    func += (tr:inout HTML.ContentEncoder, self:Self)
    {
        tr[.td] { $0.class = "refname" } = self.name
        tr[.td]
        {
            $0.class = "commit"
            $0.title = self.sha1

        } = self.sha1?.prefix(7) ?? ""

        tr[.td] { $0.class = "release" } = self.release ? "yes" : "no"
        tr[.td, { $0.class = "version" }]
        {
            if  let volume:Unidoc.VolumeMetadata = self.volume
            {
                $0[.a] { $0.href = "\(Swiftinit.Docs[volume])" } = "\(self.version)"
            }
            else
            {
                $0[.span]
                {
                    $0.title = "No documentation has been generated for this version."
                } = "\(self.version)"
            }
        }
        tr[.td, { $0.class = "graph" }]
        {
            if  let graph:Unidoc.EditionOutput.Graph = self.graph
            {
                $0[.span] { $0.class = "abi" } = "\(graph.abi)"
                $0 += " "
                $0[.span]
                {
                    $0.class = "kb"
                    $0.title = "\(graph.bytes) bytes"

                } = "(\(graph.bytes >> 10) kb)"
            }
            else
            {
                $0[.span]
                {
                    $0.title = "No symbol graph has been built for this version."
                }
            }
        }
    }
}
