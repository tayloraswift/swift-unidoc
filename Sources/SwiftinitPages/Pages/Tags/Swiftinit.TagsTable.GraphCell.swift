import HTML
import Media
import Symbols

extension Swiftinit.TagsTable
{
    struct GraphCell
    {
        private
        let package:Symbol.Package
        private
        let graph:Unidoc.VersionsQuery.Graph
        let view:Swiftinit.Permissions

        init(package:Symbol.Package,
            graph:Unidoc.VersionsQuery.Graph,
            view:Swiftinit.Permissions)
        {
            self.package = package
            self.graph = graph
            self.view = view
        }
    }
}
extension Swiftinit.TagsTable.GraphCell
{
    private
    var uplink:Tool
    {
        .init(edition: self.graph.id, package: self.package, label: "Uplink")
    }

    private
    var unlink:Tool
    {
        .init(edition: self.graph.id, package: self.package, label: "Unlink")
    }

    private
    var delete:Tool
    {
        .init(edition: self.graph.id, package: self.package, label: "Delete")
    }
}
extension Swiftinit.TagsTable.GraphCell:HTML.OutputStreamable
{
    static
    func += (td:inout HTML.ContentEncoder, self:Self)
    {
        let size:Int = self.graph.inlineBytes ?? self.graph.remoteBytes

        td[.span]
        {
            switch self.graph.action
            {
            case nil:
                $0.class = "abi"

            case .uplinkInitial, .uplinkRefresh:
                $0.class = "abi uplinking"
                $0.title = """
                This symbol graph is currently queued for documentation generation.
                """

            case .unlink:
                $0.class = "abi unlinking"
                $0.title = """
                This symbol graph is currently queued for documentation removal.
                """

            case .delete:
                $0.class = "abi deleting"
                $0.title = """
                This symbol graph is currently queued for deletion.
                """
            }
        } = "\(self.graph.abi)"

        td += " "

        td[.span]
        {
            $0.class = "kb"
            $0.title = "\(size) bytes, \(self.graph.inlineBytes ?? 0) bytes on disk"

        } = "(\(size >> 10) kb)"

        guard case .administratrix? = self.view.global
        else
        {
            return
        }

        td[.form]
        {
            $0.enctype = "\(MediaType.application(.x_www_form_urlencoded))"
            $0.action = "\(Swiftinit.API[.uplink])"
            $0.method = "post"
        } = self.uplink

        td[.form]
        {
            $0.enctype = "\(MediaType.application(.x_www_form_urlencoded))"
            $0.action = "\(Swiftinit.API[.unlink, really: false])"
            $0.method = "post"
        } = self.unlink

        td[.form]
        {
            $0.enctype = "\(MediaType.application(.x_www_form_urlencoded))"
            $0.action = "\(Swiftinit.API[.delete, really: false])"
            $0.method = "post"
        } = self.delete

        td[.a]
        {
            let path:Unidoc.GraphPath = .init(edition: self.graph.id, type: .bson_zz)

            $0.target = "_blank"
            $0.href = """
            https://s3.console.aws.amazon.com/s3/object/symbolgraphs\
            ?region=us-east-1&bucketType=general&prefix=\(path.prefix)
            """
        } = "S3"
    }
}
