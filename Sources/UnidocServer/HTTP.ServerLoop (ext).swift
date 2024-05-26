import HTTP
import HTTPServer
import MongoDB

extension HTTP.ServerLoop where Self:Unidoc.ServerLoop
{
    public nonisolated
    func run() async throws
    {
        try await self._setup()
        try await withThrowingTaskGroup(of: Void.self)
        {
            (tasks:inout ThrowingTaskGroup<Void, any Error>) in

            for plugin:any Unidoc.ServerPlugin in self.plugins.values
            {
                tasks.addTask
                {
                    try await plugin.run(in: self.context, with: self.db)
                }
            }
            do
            {
                tasks.addTask
                {
                    try await self.serve(from: ("::", self.options.port),
                        as: self.options.authority,
                        on: self.context.threads,
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
