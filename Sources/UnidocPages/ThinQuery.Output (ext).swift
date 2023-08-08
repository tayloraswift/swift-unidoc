import HTTPServer
import UnidocQueries
import UnidocSelectors
import URI

extension ThinQuery.Output:ServerResponseFactory
{
    public
    func response(for _:URI) throws -> ServerResponse
    {
        if  LookupMode.self is Selector.Planes.Type
        {
            fatalError("unimplemented")
        }
        else if let redirect:URI = self.redirect
        {
            return .redirect(.permanent("\(redirect)"))
        }
        else
        {
            return .resource(.init(.none,
                content: .text("Record not found."),
                type: .text(.plain, charset: .utf8)))
        }
    }

    private
    var redirect:URI?
    {
        switch self.masters.first
        {
        case .article(let master)?:
            return .init(article: master, in: self.trunk)

        case .culture(let master)?:
            return .init(culture: master, in: self.trunk)

        case .decl(let master)?:
            return .init(decl: master, in: self.trunk, disambiguate: self.masters.count == 1)

        case .file?, nil:
            return nil
        }
    }
}
