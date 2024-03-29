import HTTP
import JSON

extension Swiftinit.ServerLoop
{
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
extension Swiftinit.ServerLoop.Promise
{
    func resume(returning response:HTTP.ServerResponse)
    {
        self.continuation.resume(returning: response)
    }

    func resume(rendering error:any Error, as format:Swiftinit.RenderFormat)
    {
        let page:Swiftinit.ServerErrorPage = .init(error: error)
        self.resume(returning: .error(page.resource(format: format)))
    }
}
