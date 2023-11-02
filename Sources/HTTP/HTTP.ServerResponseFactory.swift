import Media

@available(*, deprecated, renamed: "HTTP.ServerResponseFactory")
public
typealias ServerResponseFactory = HTTP.ServerResponseFactory

extension HTTP
{
    public
    typealias ServerResponseFactory = _HTTPServerResponseFactory
}

/// The name of this protocol is ``HTTP.ServerResponseFactory``.
public
protocol _HTTPServerResponseFactory<Assets>
{
    associatedtype Assets

    func response(with assets:Assets, as type:AcceptType?) throws -> HTTP.ServerResponse
}
