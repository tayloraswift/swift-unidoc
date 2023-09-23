import Media

public
protocol ServerResponseFactory
{
    func response(as type:AcceptType?) throws -> ServerResponse
}
