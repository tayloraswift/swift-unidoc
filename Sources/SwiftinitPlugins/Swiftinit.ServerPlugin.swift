import SwiftinitRender

extension Swiftinit
{
    public
    protocol ServerPlugin:Identifiable<String>, Sendable
    {
        associatedtype StatusPage:Unidoc.RenderablePage & Sendable

        var status:AtomicPointer<StatusPage> { get }

        func run(in context:ServerPluginContext, with db:DB) async throws
    }
}
