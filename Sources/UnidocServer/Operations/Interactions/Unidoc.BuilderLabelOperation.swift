import HTTP
import JSON
import MongoQL
import UnidocDB

extension Unidoc
{
    struct BuilderLabelOperation:Sendable
    {
        let prompt:Unidoc.BuildLabelsPrompt

        init(prompt:Unidoc.BuildLabelsPrompt)
        {
            self.prompt = prompt
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
        let labels:Unidoc.BuildLabels = try await server.db.unidoc.answer(
            prompt: self.prompt,
            with: session)
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
