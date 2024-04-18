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
        guard
        let labels:Unidoc.BuildLabels = try await server.db.unidoc.answer(
            prompt: self.prompt,
            with: session)
        else
        {
            return nil
        }

        return .object(with: labels.encode(to:))
    }
}
