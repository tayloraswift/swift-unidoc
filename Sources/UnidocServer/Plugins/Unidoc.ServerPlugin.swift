import UnidocDB
import UnidocRender

extension Unidoc
{
    public
    protocol ServerPlugin:Identifiable<String>, Sendable
    {
        associatedtype StatusPage:RenderablePage & Sendable

        var status:AtomicPointer<StatusPage> { get }

        func run(in context:ServerPluginContext, with db:Database) async throws
    }
}
extension Unidoc.ServerPlugin
{
    var page:(any Unidoc.RenderablePage)? { self.status.load() }
}
