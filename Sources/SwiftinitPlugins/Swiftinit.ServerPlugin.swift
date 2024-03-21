import SwiftinitRender

extension Swiftinit
{
    public
    protocol ServerPlugin:Identifiable<String>, Sendable
    {
        associatedtype StatusPage:RenderablePage & Sendable

        var status:AtomicPointer<StatusPage> { get }

        func run(in context:ServerPluginContext, with db:DB) async throws
    }
}
