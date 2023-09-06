public
protocol ServerResponseFactory<Request>
{
    associatedtype Request

    func response(for requested:Request) throws -> ServerResponse
}
