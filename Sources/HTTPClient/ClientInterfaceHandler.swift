import NIOCore
import NIOHPACK
import NIOHTTP2

/// An HTTP/2 handler whose sole purpose is to initiate HTTP/2 streams in parallel by
/// creating ``ClientStreamHandler``s for the multiplexed streams and configuring them to
/// return their responses to the owner of the requests.
final
class ClientInterfaceHandler
{
    private
    let multiplexer:NIOHTTP2Handler.StreamMultiplexer

    init(multiplexer:NIOHTTP2Handler.StreamMultiplexer)
    {
        self.multiplexer = multiplexer
    }
}
extension ClientInterfaceHandler:ChannelOutboundHandler
{
    typealias OutboundOut = HTTP2Frame
    typealias OutboundIn =
    (
        owner:AsyncThrowingStream<HTTP2Client.Facet, any Error>.Continuation,
        batch:[HPACKHeaders]
    )

    func write(context:ChannelHandlerContext, data:NIOAny, promise:EventLoopPromise<Void>?)
    {
        let owner:AsyncThrowingStream<HTTP2Client.Facet, any Error>.Continuation
        let batch:[HPACKHeaders]

        (owner, batch) = self.unwrapOutboundIn(data)

        for request:HPACKHeaders in batch
        {
            self.multiplexer.createStreamChannel
            {
                $0.pipeline.addHandler(ClientStreamHandler.init(owner: owner))
            }
                .whenComplete
            {
                switch $0
                {
                case .success(let stream):
                    stream.write(HTTP2Frame.FramePayload.headers(
                        HTTP2Frame.FramePayload.Headers.init(
                            headers: request,
                            endStream: true)),
                        promise: nil)

                    stream.flush()

                case .failure(let error):
                    owner.finish(throwing: error)
                    context.channel.close(promise: nil)
                }
            }
        }
    }
}
