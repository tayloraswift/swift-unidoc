import HTTP
import NIOCore
import NIOHTTP1

extension HTTP
{
    final
    class ServerRedirectorHandler
    {
        private
        let binding:Origin

        init(binding:Origin)
        {
            self.binding = binding
        }
    }
}
extension HTTP.ServerRedirectorHandler:ChannelInboundHandler
{
    typealias InboundIn = HTTPServerRequestPart
    typealias OutboundOut = HTTPServerResponsePart

    func channelReadComplete(context:ChannelHandlerContext)
    {
        context.flush()
    }
    func channelRead(context:ChannelHandlerContext, data:NIOAny)
    {
        guard case .head(let request) = self.unwrapInboundIn(data)
        else
        {
            return
        }

        let url:String = "\(self.binding)\(request.uri)"
        let head:HTTPResponseHead = .init(version: .http1_1,
            status: .permanentRedirect,
            headers: ["location": url])

        context.write(self.wrapOutboundOut(.head(head)), promise: nil)
        context.writeAndFlush(self.wrapOutboundOut(.end(nil)), promise: nil)
        context.close(promise: nil)
    }
}
