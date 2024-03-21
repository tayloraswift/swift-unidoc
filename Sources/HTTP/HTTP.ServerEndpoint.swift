import Media

extension HTTP
{
    public
    protocol ServerEndpoint<Format>
    {
        associatedtype Format

        consuming
        func response(as format:Format) throws -> HTTP.ServerResponse
    }
}
