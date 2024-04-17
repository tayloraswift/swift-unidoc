import Atomics
import GitHubAPI
import HTTP
import HTTPClient
import HTTPServer
import IP
import Media
import MongoDB
import NIOCore
import NIOHTTP1
import NIOPosix
import NIOSSL
import S3
import UnidocUI
import UnidocDB
import UnidocProfiling
import UnidocQueries
import UnidocRecords
import UnidocServer

extension Unidoc.ServerLoop
{
    init(
        context:Unidoc.ServerPluginContext,
        options:Unidoc.ServerOptions,
        mongodb:Mongo.SessionPool) async throws
    {
        self.init(
            plugins: options.plugins.reduce(into: [:]) { $0[$1.id] = $1 },
            context: context,
            options: options,
            db: .init(sessions: mongodb,
                unidoc: await .setup(as: "unidoc", in: mongodb))
            {
                //  200 API calls per hour.
                $0.apiLimitInterval = .seconds(3600)
                $0.apiLimitPerReset = 200
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
        let session:Mongo.Session = try await .init(from: self.db.sessions)

        //  Create the machine user, if it doesn’t exist. Don’t store the cookie, since we
        //  want to be able to change it without restarting the server.
        let _:Unidoc.UserSecrets = try await self.db.users.update(user: .machine(0),
            with: session)

        _ = consume session

        try await withThrowingTaskGroup(of: Void.self)
        {
            (tasks:inout ThrowingTaskGroup<Void, any Error>) in

            var policy:Swiftinit.PolicyPlugin? = nil
            for plugin:any Unidoc.ServerPlugin in self.plugins.values
            {
                if  case let plugin as Swiftinit.PolicyPlugin = plugin
                {
                    policy = plugin
                }

                tasks.addTask
                {
                    try await plugin.run(in: self.context, with: self.db)
                }
            }
            do
            {
                let policy:Swiftinit.PolicyPlugin? = consume policy

                tasks.addTask
                {
                    try await self.serve(from: ("::", self.port),
                        as: self.authority,
                        on: self.context.threads,
                        policy: policy)
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
