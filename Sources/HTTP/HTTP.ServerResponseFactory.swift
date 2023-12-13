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
protocol _HTTPServerResponseFactory<Format>
{
    associatedtype Format

    func response(as format:Format) throws -> HTTP.ServerResponse
}
