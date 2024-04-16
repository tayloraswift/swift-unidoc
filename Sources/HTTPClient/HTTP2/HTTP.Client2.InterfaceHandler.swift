import NIOCore
import NIOHPACK
import NIOHTTP2

extension ChannelHandlerContext:@unchecked Sendable
{
}

extension HTTP.Client2
{
    /// An HTTP/2 handler whose sole purpose is to initiate HTTP/2 streams in parallel by
    /// creating ``ClientStreamHandler``s for the multiplexed streams and configuring them to
    /// return their responses to the owner of the requests.
    final
    class InterfaceHandler
    {
        private
        let multiplexer:NIOHTTP2Handler.StreamMultiplexer
        private
        var owner:AsyncThrowingStream<HTTP.Client2.Facet, any Error>.Continuation?

        init(multiplexer:NIOHTTP2Handler.StreamMultiplexer)
        {
            self.multiplexer = multiplexer
            self.owner = nil
        }

        deinit
        {
            if  case _? = self.owner
            {
                fatalError("ClientInterfaceHandler deinitialized with stream attached!")
            }
        }
    }
}
extension HTTP.Client2.InterfaceHandler:ChannelHandler
{
    func handlerRemoved(context:ChannelHandlerContext)
    {
        self.owner?.finish()
        self.owner = nil
    }
}
extension HTTP.Client2.InterfaceHandler:ChannelOutboundHandler
{
    typealias OutboundOut = HTTP2Frame
    typealias OutboundIn =
    (
        owner:AsyncThrowingStream<HTTP.Client2.Facet, any Error>.Continuation,
        batch:[HTTP.Client2.Request]
    )

    func write(context:ChannelHandlerContext, data:NIOAny, promise:EventLoopPromise<Void>?)
    {
        let owner:AsyncThrowingStream<HTTP.Client2.Facet, any Error>.Continuation
        let batch:[HTTP.Client2.Request]

        (owner, batch) = self.unwrapOutboundIn(data)

        self.owner?.finish()
        self.owner = owner

        for request:HTTP.Client2.Request in batch
        {
            self.multiplexer.createStreamChannel
            {
                $0.pipeline.addHandler(HTTP.Client2.StreamHandler.init(owner: owner))
            }
                .whenComplete
            {
                switch $0
                {
                case .success(let stream):
                    if  let body:ByteBuffer = request.body
                    {
                        stream.write(HTTP2Frame.FramePayload.headers(
                            HTTP2Frame.FramePayload.Headers.init(
                                headers: request.headers,
                                endStream: false)),
                            promise: nil)
                        stream.writeAndFlush(HTTP2Frame.FramePayload.data(
                            HTTP2Frame.FramePayload.Data.init(
                                data: .byteBuffer(body),
                                endStream: true)),
                            promise: nil)
                    }
                    else
                    {
                        stream.writeAndFlush(HTTP2Frame.FramePayload.headers(
                            HTTP2Frame.FramePayload.Headers.init(
                                headers: request.headers,
                                endStream: true)),
                            promise: nil)
                    }

                case .failure(let error):
                    owner.finish(throwing: error)
                    context.channel.close(promise: nil)
                }
            }
        }
    }
}
