import HTTP
import UnidocRender

extension Unidoc
{
    struct PluginOperation
    {
        let plugin:String
        let action:Action

        init(plugin:String, action:Action)
        {
            self.plugin = plugin
            self.action = action
        }
    }
}
extension Unidoc.PluginOperation:Unidoc.AdministrativeOperation
{
    func load(from server:Unidoc.Server,
        db:Unidoc.DB,
        as format:Unidoc.RenderFormat) async throws -> HTTP.ServerResponse?
    {
        guard
        let handle:Unidoc.PluginHandle = server.plugins[self.plugin]
        else
        {
            return .notFound("No such plugin")
        }

        switch self.action
        {
        case .pause:
            handle.active.store(false, ordering: .relaxed)

        case .start:
            handle.active.store(true, ordering: .relaxed)

        case .status:
            let statusPage:Unidoc.PluginStatusPage = .init(
                messages: await server.logger?.messages(from: self.plugin) ?? [],
                plugin: type(of: handle.plugin),
                active: handle.active.load(ordering: .relaxed))

            return .ok(statusPage.resource(format: format))
        }

        return .redirect(.temporary("\(Unidoc.ServerRoot.plugin / self.plugin)"))
    }
}
