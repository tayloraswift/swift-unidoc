import HTTP
import UnidocQueries
import URI

extension PackageEditionsQuery.Output:ServerResponseFactory
{
    public
    func response(for _:URI) throws -> ServerResponse
    {
        let list:Site.Tags.List = .init(from: self)
        return .ok(list.resource())
    }
}
