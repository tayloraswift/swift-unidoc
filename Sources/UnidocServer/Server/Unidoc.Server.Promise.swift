import HTTP
import HTTPServer

extension Unidoc.Server
{
    @frozen public
    struct Promise:Sendable
    {
        private
        let continuation:CheckedContinuation<HTTP.ServerResponse, Never>

        init(_ continuation:CheckedContinuation<HTTP.ServerResponse, Never>)
        {
            self.continuation = continuation
        }
    }
}
extension Unidoc.Server.Promise
{
    func resume(returning response:HTTP.ServerResponse)
    {
        self.continuation.resume(returning: response)
    }

    func resume(rendering error:any Error, as format:Unidoc.RenderFormat)
    {
        Log[.error] = "\(error)"

        let page:Unidoc.ServerErrorPage = .init(error: error)
        self.resume(returning: .error(page.resource(format: format)))
    }
}
