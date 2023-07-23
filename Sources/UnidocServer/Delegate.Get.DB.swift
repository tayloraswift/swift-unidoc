import HTML
import HTTPServer
import MongoDB
import UnidocDatabase
import URI

extension Delegate.Get
{
    struct DB:Sendable
    {
        let requested:URI

        var canonical:Bool
        var explain:Bool
        var query:DeepQuery?

        init(canonical:Bool, explain:Bool, query:DeepQuery?, uri:URI)
        {
            self.requested = uri

            self.canonical = canonical
            self.explain = explain
            self.query = query
        }
    }
}
extension Delegate.Get.DB
{
    func load(from database:Database, pool:Mongo.SessionPool) async throws -> ServerResponse?
    {
        guard let query:DeepQuery = self.query
        else
        {
            // unimplemented
            return nil
        }

        let session:Mongo.Session = try await .init(from: pool)

        if  self.explain
        {
            let explanation:String = try await database.explain(
                query: query,
                with: session)

            return .resource(.init(.one(canonical: nil),
                content: .text(explanation),
                type: .text(.plain, charset: .utf8)))
        }
        else if
            let page:Site.Docs.DeepPage = .init(try await database.execute(
                query: query,
                with: session))
        {
            let html:HTML = .document { $0[.html] { $0.lang = "en" } = page }

            return .resource(.init(.one(canonical: "\(page.location)"),
                content: .binary(html.utf8),
                type: .text(.html, charset: .utf8)))
        }
        else
        {
            return nil
        }
    }
}
