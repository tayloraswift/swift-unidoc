import Media

@available(*, deprecated, renamed: "HTTP.ServerEndpoint")
public
typealias ServerResponseFactory = HTTP.ServerEndpoint

extension HTTP
{
    public
    typealias ServerEndpoint = _HTTPServerEndpoint
}

/// The name of this protocol is ``HTTP.ServerEndpoint``.
public
protocol _HTTPServerEndpoint<Format>
{
    associatedtype Format

    consuming
    func response(as format:Format) throws -> HTTP.ServerResponse
}
