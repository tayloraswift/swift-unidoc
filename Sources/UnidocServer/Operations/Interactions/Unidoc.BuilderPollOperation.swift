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
    func load(from server:Unidoc.Server,
        with session:Mongo.Session,
        as _:Unidoc.RenderFormat) async throws -> HTTP.ServerResponse?
    {
        let labels:Unidoc.BuildLabels? = try await withThrowingTaskGroup(
            of: Unidoc.BuildLabels?.self)
        {
            $0.addTask
            {
                try await Task.sleep(for: .seconds(30))
                return nil
            }
            $0.addTask
            {
                try await server.builds.match(builder: self.id)
            }

            for try await labels:Unidoc.BuildLabels? in $0
            {
                $0.cancelAll()
                return labels
            }

            return nil
        }

        guard
        let labels:Unidoc.BuildLabels
        else
        {
            //  Return heartbeat.
            return .noContent
        }

        let json:JSON = .object(with: labels.encode(to:))
        return .ok(.init(content: .init(
            body: .binary(json.utf8),
            type: .application(.json, charset: .utf8))))
    }
}
