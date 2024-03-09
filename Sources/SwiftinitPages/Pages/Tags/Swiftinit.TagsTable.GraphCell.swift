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
        let view:Swiftinit.ViewMode

        init(package:Symbol.Package, graph:Unidoc.VersionsQuery.Graph, view:Swiftinit.ViewMode)
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
}
extension Swiftinit.TagsTable.GraphCell:HTML.OutputStreamable
{
    static
    func += (td:inout HTML.ContentEncoder, self:Self)
    {
        let size:Int = self.graph.inlineBytes ?? self.graph.remoteBytes

        td[.span]
        {
            $0.class = self.graph.link != nil ? "abi uplinking" : "abi"
            $0.title = self.graph.link != nil ? """
                This symbol graph is currently queued for documentation generation.
                """ : nil
        } = "\(self.graph.abi)"

        td += " "

        td[.span]
        {
            $0.class = "kb"
            $0.title = "\(size) bytes, \(self.graph.inlineBytes ?? 0) bytes on disk"

        } = "(\(size >> 10) kb)"

        guard case .maintainer = self.view
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
            $0.action = "\(Swiftinit.API[.unlink])"
            $0.method = "post"
        } = self.unlink
    }
}
