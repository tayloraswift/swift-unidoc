import HTTP
import MongoDB
import _MongoDB

extension Unidoc
{
    protocol ExplainableOperation<Query>
    {
        associatedtype Query:Mongo.PipelineQuery
        var query:Query { get }
    }
}
extension Unidoc.ExplainableOperation
{
    func explain(with db:Unidoc.DB) async throws -> HTTP.ServerResponse
    {
        .ok(.init(content: .init(
            body: .string(try await db.explain(query: self.query)),
            type: .text(.plain, charset: .utf8))))
    }
}
