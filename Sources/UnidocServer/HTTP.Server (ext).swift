import HTTP
import HTTPServer
import MongoDB

extension HTTP.Server where Self:Unidoc.Server
{
    public
    func run(on port:Int) async throws
    {
        try await self._setup()
        try await withThrowingTaskGroup(of: Void.self)
        {
            (tasks:inout ThrowingTaskGroup<Void, any Error>) in

            for handle:Unidoc.PluginHandle in self.plugins.values
            {
                tasks.addTask
                {
                    try await self.run(plugin: handle.plugin, while: handle.active)
                }
            }

            tasks.addTask
            {
                try await self.serve(from: ("::", port),
                    as: self.options.authority,
                    on: .singleton,
                    policy: self.policy)
            }
            tasks.addTask
            {
                try await self.update()
            }
            tasks.addTask
            {
                try await self.paint()
            }

            for try await _:Void in tasks
            {
                tasks.cancelAll()
            }
        }
    }
}
