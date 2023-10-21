import Media

public
protocol ServerResponseFactory<Assets>
{
    associatedtype Assets

    func response(with assets:Assets, as type:AcceptType?) throws -> ServerResponse
}
