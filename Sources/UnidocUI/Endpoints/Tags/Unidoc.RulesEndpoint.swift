import HTTP
import MongoDB
import Symbols
import UnidocDB
import UnidocQueries
import UnidocRender
import URI

extension Unidoc
{
    @frozen public
    struct RulesEndpoint
    {
        public
        let query:RulesQuery
        public
        var value:RulesOutput?

        @inlinable public
        init(query:RulesQuery)
        {
            self.query = query
            self.value = nil
        }
    }
}
extension Unidoc.RulesEndpoint
{
    @inlinable public static
    subscript(package:Symbol.Package) -> URI { Unidoc.ServerRoot.rules / "\(package)" }
}
extension Unidoc.RulesEndpoint:Mongo.PipelineEndpoint, Mongo.SingleOutputEndpoint
{
    @inlinable public static
    var replica:Mongo.ReadPreference { .nearest }
}
extension Unidoc.RulesEndpoint:HTTP.ServerEndpoint
{
    public consuming
    func response(as format:Unidoc.RenderFormat) -> HTTP.ServerResponse
    {
        guard
        let output:Unidoc.RulesOutput = self.value
        else
        {
            return .error("Query for endpoint '\(Self.self)' returned no outputs!")
        }

        let display:Unidoc.RulesPage = .init(package: output.package,
            editors: output.editors,
            members: output.members,
            owner: output.owner,
            view: format.security.permissions(package: output.package, user: output.user))

        return .ok(display.resource(format: format))
    }
}
