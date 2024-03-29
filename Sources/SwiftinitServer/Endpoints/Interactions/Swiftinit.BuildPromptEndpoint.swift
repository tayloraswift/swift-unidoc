import JSON
import MongoQL
import UnidocDB

extension Swiftinit
{
    struct BuildPromptEndpoint:Sendable
    {
        let prompt:Unidoc.BuildPrompt

        init(prompt:Unidoc.BuildPrompt)
        {
            self.prompt = prompt
        }
    }
}
extension Swiftinit.BuildPromptEndpoint:Swiftinit.MachineEndpoint
{
    func load(from server:borrowing Swiftinit.Server,
        with session:Mongo.Session) async throws -> JSON?
    {
        try await server.db.unidoc.answer(prompt: self.prompt, with: session)
    }
}
