import HTTP
import HTTPServer
import MongoDB

extension HTTP.Server where Self:Unidoc.Server
{
    public
    func run() async throws
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
            do
            {
                tasks.addTask
                {
                    try await self.serve(from: ("::", self.options.port),
                        as: self.options.authority,
                        on: .singleton,
                        policy: self.policy)
                }
                tasks.addTask
                {
                    try await self.update()
                }
            }

            for try await _:Void in tasks
            {
                tasks.cancelAll()
            }
        }
    }
}
