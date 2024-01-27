import NIOCore
import NIOHTTP1

extension HTTP1Client
{
    final
    class InterfaceHandler
    {
        private
        var request:CheckedContinuation<Facet, any Error>?
        private
        var facet:Facet

        init()
        {
            self.request = nil
            self.facet = .init()
        }

        deinit
        {
            if  case _? = self.request
            {
                fatalError("InterfaceHandler deinitialized with continuation attached!")
            }
        }
    }
}
extension HTTP1Client.InterfaceHandler:ChannelHandler
{
    func handlerRemoved(context:ChannelHandlerContext)
    {
        self.request?.resume(throwing: HTTP1Client.UnexpectedDisconnectionError.init())
        self.request = nil
    }
    func errorCaught(context:ChannelHandlerContext, error:any Error)
    {
        self.request?.resume(throwing: error)
        self.request = nil
    }
}
extension HTTP1Client.InterfaceHandler:ChannelInboundHandler
{
    typealias InboundIn = HTTPClientResponsePart

    func channelRead(context:ChannelHandlerContext, data:NIOAny)
    {
        if  case nil = self.request
        {
            //  Unsolicited response.
            context.channel.close(promise: nil)
            return
        }

        switch self.unwrapInboundIn(data)
        {
        case .head(let head):
            self.facet.head = head

            if  let length:String = head.headers["content-length"].first,
                let length:Int = .init(length)
            {
                self.facet.body.reserveCapacity(length)
            }

        case .body(let buffer):
            buffer.withUnsafeReadableBytes
            {
                self.facet.body += $0
            }

        case .end(_):
            self.request?.resume(returning: self.facet)
            self.request = nil
            self.facet = .init()
        }
    }
}
extension HTTP1Client.InterfaceHandler:ChannelOutboundHandler
{
    typealias OutboundOut = HTTPClientRequestPart
    typealias OutboundIn =
    (
        promise:CheckedContinuation<HTTP1Client.Facet, any Error>,
        request:HTTP1Client.Request
    )

    func write(context:ChannelHandlerContext, data:NIOAny, promise:EventLoopPromise<Void>?)
    {
        let request:HTTP1Client.Request

        (self.request, request) = self.unwrapOutboundIn(data)

        let head:HTTPRequestHead = .init(version: .http1_1,
            method: request.method,
            uri: request.path,
            headers: request.head)

        if  let body:ByteBuffer = request.body
        {
            context.write(self.wrapOutboundOut(.head(head)), promise: nil)
            context.write(self.wrapOutboundOut(.body(.byteBuffer(body))), promise: nil)
            context.writeAndFlush(self.wrapOutboundOut(.end(nil)), promise: promise)
        }
        else
        {
            context.writeAndFlush(self.wrapOutboundOut(.head(head)), promise: promise)
        }
    }
}
