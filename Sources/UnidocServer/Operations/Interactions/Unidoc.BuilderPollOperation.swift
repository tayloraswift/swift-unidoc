import HTTP
import JSON
import MongoQL
import UnidocDB

extension Unidoc
{
    struct BuilderPollOperation:Sendable
    {
        let id:Unidoc.Account

        init(id:Unidoc.Account)
        {
            self.id = id
        }
    }
}
extension Unidoc.BuilderPollOperation:Unidoc.MachineOperation
{
    func load(from server:borrowing Unidoc.Server,
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

            guard try await server.db.packageBuilds.assignBuild(request: type.selector,
                package: build.id,
                builder: self.id,
                with: session)
            else
            {
                //  We lost the race.
                continue polling
            }

            let prompt:Unidoc.BuildLabelsPrompt
            switch type
            {
            case .latest(let series, force: let force):
                prompt = .package(build.id, series: series, force: force)

            case .id(let id, force: let force):
                prompt = .edition(id, force: force)
            }

            if  let labels:Unidoc.BuildLabels = try await server.db.unidoc.answer(
                    prompt: prompt,
                    with: session)
            {
                return .object(with: labels.encode(to:))
            }
            else if
                let _:Unidoc.BuildMetadata = try await server.db.packageBuilds.finishBuild(
                    package: build.id,
                    failure: .noValidVersion,
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
