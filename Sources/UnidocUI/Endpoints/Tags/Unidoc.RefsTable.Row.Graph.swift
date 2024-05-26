import HTML
import Media
import SemanticVersions
import Symbols

extension Unidoc.RefsTable.Row
{
    struct Graph
    {
        let package:Symbol.Package
        let version:String

        private
        let state:State
        private
        let view:Unidoc.Permissions

        init(
            package:Symbol.Package,
            version:String,
            state:State,
            view:Unidoc.Permissions)
        {
            self.package = package
            self.version = version
            self.state = state
            self.view = view
        }
    }
}
extension Unidoc.RefsTable.Row.Graph
{
    private
    var id:Unidoc.Edition
    {
        switch self.state
        {
        case .some(let graph):  graph.id
        case .none(let id):     id
        }
    }
}
extension Unidoc.RefsTable.Row.Graph:HTML.OutputStreamable
{
    static
    func += (td:inout HTML.ContentEncoder, self:Self)
    {
        td[.div]
        {
            guard case .some(let graph) = self.state,
            let abi:PatchVersion = graph.abi
            else
            {
                $0[.span] { $0.title = "No symbol graph has been built for this version." }
                return
            }

            let size:Int = graph.inlineBytes ?? graph.remoteBytes

            $0[.span]
            {
                switch graph.action
                {
                case nil:
                    $0.class = "graph"

                case .uplinkInitial, .uplinkRefresh:
                    $0.class = "graph uplinking"
                    $0.title = """
                    This symbol graph is currently queued for documentation generation.
                    """

                case .unlink:
                    $0.class = "graph unlinking"
                    $0.title = """
                    This symbol graph is currently queued for documentation removal.
                    """

                case .delete:
                    $0.class = "graph deleting"
                    $0.title = """
                    This symbol graph is currently queued for deletion.
                    """
                }
            } = "\(abi)"

            $0 += " "

            $0[.span]
            {
                $0.class = "kb"
                $0.title = "\(size) bytes, \(graph.inlineBytes ?? 0) bytes on disk"

            } = "(\(size >> 10) kb)"
        }

        guard self.view.editor
        else
        {
            return
        }

        td[.div, { $0.class = "menu" }]
        {
            $0[.button] = "•••"
            $0[.ul]
            {
                $0[.li]
                {
                    $0[.form]
                    {
                        $0.enctype = "\(MediaType.application(.x_www_form_urlencoded))"
                        $0.action = "\(Unidoc.Post[.build, really: false])"
                        $0.method = "post"
                    } = Unidoc.BuildButton.edition(id: self.id,
                        package: self.package,
                        version: self.version)
                }

                guard
                case .administratrix? = self.view.global,
                case .some(let graph) = self.state
                else
                {
                    return
                }

                for (label, action, proceed):(String, Unidoc.PostAction, Bool) in [
                    ("Uplink", .uplink, true),
                    ("Unlink", .unlink, false),
                    ("Delete", .delete, false)
                ]
                {
                    $0[.li]
                    {
                        $0[.form]
                        {
                            $0.enctype = "\(MediaType.application(.x_www_form_urlencoded))"
                            $0.action = "\(Unidoc.Post[action, really: proceed])"
                            $0.method = "post"
                        } = Tool.init(edition: graph.id, package: self.package, label: label)
                    }
                }

                $0[.li]
                {
                    $0[.a]
                    {
                        let path:Unidoc.GraphPath = .init(edition: graph.id,
                            type: .bson_zz)

                        $0.target = "_blank"
                        $0.rel = .external
                        $0.href = """
                        https://s3.console.aws.amazon.com/s3/object/symbolgraphs\
                        ?region=us-east-1&bucketType=general&prefix=\(path.prefix)
                        """
                    } = "Inspect object"
                }
            }
        }
    }
}
