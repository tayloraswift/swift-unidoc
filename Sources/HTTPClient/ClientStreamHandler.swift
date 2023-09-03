import NIOCore
import NIOHTTP2

/// A simple channel handler that collates and forwards incoming HTTP/2 frames to its owner.
final
class ClientStreamHandler
{
    private
    var owner:AsyncThrowingStream<ClientInterface.Facet, any Error>.Continuation?
    private
    var facet:ClientInterface.Facet

    init(owner:AsyncThrowingStream<ClientInterface.Facet, any Error>.Continuation?)
    {
        self.owner = owner
        self.facet = .init()
    }

    deinit
    {
        self.owner?.finish()
    }
}
extension ClientStreamHandler:ChannelInboundHandler
{
    typealias InboundIn = HTTP2Frame.FramePayload

    func errorCaught(context:ChannelHandlerContext, error:any Error)
    {
        self.owner?.finish(throwing: error)
        self.owner = nil
    }

    func channelRead(context:ChannelHandlerContext, data:NIOAny)
    {
        if  case nil = self.owner
        {
            //  Unsolicited response.
            context.channel.close(promise: nil)
            return
        }

        let payload:HTTP2Frame.FramePayload = self.unwrapInboundIn(data)
        do
        {
            guard try self.facet.update(with: payload)
            else
            {
                // More to come.
                return
            }

            self.owner?.yield(self.facet)
            self.owner = nil
            self.facet = .init()
        }
        catch let error
        {
            self.owner?.finish(throwing: error)
            self.owner = nil
        }

        context.channel.close(promise: nil)
    }
}
