import HTTP
import JSON
import MongoQL
import UnidocDB

extension Unidoc
{
    struct BuilderLabelOperation:Sendable
    {
        let request:Unidoc.BuildRequest<Unidoc.Package>

        init(request:Unidoc.BuildRequest<Unidoc.Package>)
        {
            self.request = request
        }
    }
}
extension Unidoc.BuilderLabelOperation:Unidoc.MachineOperation
{
    func load(from server:Unidoc.Server,
        with session:Mongo.Session,
        as _:Unidoc.RenderFormat) async throws -> HTTP.ServerResponse?
    {
        guard
        let edition:Unidoc.EditionState = try await server.db.unidoc.editionState(
            of: self.request.version,
            with: session),
        let labels:Unidoc.BuildLabels = try await server.github?.resolve(edition,
            rebuild: self.request.rebuild)
        else
        {
            return nil
        }

        let json:JSON = .object(with: labels.encode(to:))
        return .ok(.init(content: .init(
            body: .binary(json.utf8),
            type: .application(.json, charset: .utf8))))
    }
}
