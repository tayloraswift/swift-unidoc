import HTTP
import JSON
import MongoQL
import UnidocDB

extension Swiftinit
{
    struct BuilderPollEndpoint:Sendable
    {
        let id:Unidoc.Account

        init(id:Unidoc.Account)
        {
            self.id = id
        }
    }
}
extension Swiftinit.BuilderPollEndpoint:Swiftinit.MachineEndpoint
{
    func load(from server:borrowing Swiftinit.Server,
        with session:Mongo.Session) async throws -> JSON?
    {
        polling:
        do
        {
            guard
            let build:Unidoc.BuildMetadata = try await server.db.packageBuilds.selectBuild(
                await: true,
                with: session),
            let type:Unidoc.BuildRequest = build.request
            else
            {
                return nil
            }

            guard try await server.db.packageBuilds.assignBuild(request: type,
                package: build.id,
                builder: self.id,
                with: session)
            else
            {
                //  We lost the race.
                continue polling
            }

            let prompt:Unidoc.BuildPrompt = .package(build.id, series: type.forced)

            if  let json:JSON = try await server.db.unidoc.answer(prompt: prompt, with: session)
            {
                return json
            }
            else if
                let _:Unidoc.BuildMetadata = try await server.db.packageBuilds.finishBuild(
                    package: build.id,
                    failure: .init(reason: .noValidVersion),
                    with: session)
            {
                continue polling
            }
            else
            {
                return nil
            }
        }
    }
}
