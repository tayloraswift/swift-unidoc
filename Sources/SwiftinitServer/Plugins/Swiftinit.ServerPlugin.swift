import SwiftinitRender

extension Swiftinit
{
    public
    typealias ServerPlugin = _SwiftinitServerPlugin
}
public
protocol _SwiftinitServerPlugin:Identifiable<String>, Sendable
{
    associatedtype StatusPage:Swiftinit.RenderablePage & Sendable

    var status:AtomicPointer<StatusPage> { get }

    func run(in context:Swiftinit.ServerPluginContext, with db:Swiftinit.DB) async throws
}
extension Swiftinit.ServerPlugin
{
    var page:(any Swiftinit.RenderablePage)? { self.status.load() }
}
