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
    func load(from server:borrowing Unidoc.Server,
        with session:Mongo.Session) async throws -> JSON?
    {
        try await server.db.unidoc.answer(prompt: self.prompt, with: session)
    }
}
