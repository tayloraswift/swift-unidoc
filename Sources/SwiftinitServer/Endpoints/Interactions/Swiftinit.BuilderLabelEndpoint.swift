import JSON
import MongoQL
import UnidocDB

extension Swiftinit
{
    struct BuilderLabelEndpoint:Sendable
    {
        let prompt:Unidoc.BuildLabelsPrompt

        init(prompt:Unidoc.BuildLabelsPrompt)
        {
            self.prompt = prompt
        }
    }
}
extension Swiftinit.BuilderLabelEndpoint:Swiftinit.MachineEndpoint
{
    func load(from server:borrowing Swiftinit.Server,
        with session:Mongo.Session) async throws -> JSON?
    {
        try await server.db.unidoc.answer(prompt: self.prompt, with: session)
    }
}
