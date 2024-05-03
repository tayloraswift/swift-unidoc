import HTTP
import HTTPServer
import MongoDB
import UnidocServer

extension Unidoc.ServerLoop
{
    init(
        context:Unidoc.ServerPluginContext,
        options:Unidoc.ServerOptions,
        mongodb:Mongo.SessionPool) async throws
    {
        let linker:Unidoc.GraphLinkerPlugin = .init(bucket: nil)

        self.init(
            plugins: [linker.id: linker],
            context: context,
            options: options,
            db: .init(sessions: mongodb,
                unidoc: await .setup(as: "unidoc", in: mongodb))
            {
                $0.apiLimitInterval = .seconds(60)
                $0.apiLimitPerReset = 10000
            })
    }
}
extension Unidoc.ServerLoop:HTTP.ServerLoop
{
}
extension Unidoc.ServerLoop
{
    nonisolated
    func run() async throws
    {
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
                    try await self.serve(from: ("::", self.port),
                        as: self.authority,
                        on: self.context.threads,
                        policy: nil as Never?)
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
