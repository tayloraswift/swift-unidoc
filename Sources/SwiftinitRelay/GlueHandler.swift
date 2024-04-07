import NIOCore

final
class GlueHandler
{
    private
    var partner:GlueHandler?

    private
    var context:ChannelHandlerContext?

    private
    var readPending:Bool

    private
    init()
    {
        self.readPending = false
    }
}
extension GlueHandler
{
    static
    func bridge() -> (GlueHandler, GlueHandler)
    {
        let bridge:(GlueHandler, GlueHandler) = (.init(), .init())

        bridge.0.partner = bridge.1
        bridge.1.partner = bridge.0

        return bridge
    }
}
extension GlueHandler
{
    private
    func partnerWrite(_ data:NIOAny)
    {
        self.context?.write(data, promise: nil)
    }

    private
    func partnerFlush()
    {
        self.context?.flush()
    }

    private
    func partnerWriteEOF()
    {
        self.context?.close(mode: .output, promise: nil)
    }

    private
    func partnerCloseFull()
    {
        self.context?.close(promise: nil)
    }

    private
    func partnerBecameWritable()
    {
        if  self.readPending
        {
            self.readPending = false
            self.context?.read()
        }
    }

    private
    var partnerWritable:Bool
    {
        self.context?.channel.isWritable ?? false
    }
}

extension GlueHandler:ChannelDuplexHandler
{
    typealias InboundIn = NIOAny
    typealias OutboundIn = NIOAny
    typealias OutboundOut = NIOAny

    func handlerAdded(context:ChannelHandlerContext)
    {
        self.context = context
    }

    func handlerRemoved(context:ChannelHandlerContext)
    {
        self.context = nil
        self.partner = nil
    }

    func channelRead(context:ChannelHandlerContext, data:NIOAny)
    {
        self.partner?.partnerWrite(data)
    }

    func channelReadComplete(context:ChannelHandlerContext)
    {
        self.partner?.partnerFlush()
    }

    func channelInactive(context:ChannelHandlerContext)
    {
        self.partner?.partnerCloseFull()
    }

    func userInboundEventTriggered(context:ChannelHandlerContext, event:Any)
    {
        if  case ChannelEvent.inputClosed = event
        {
            self.partner?.partnerWriteEOF()
        }
    }

    func errorCaught(context:ChannelHandlerContext, error:any Error)
    {
        self.partner?.partnerCloseFull()
    }

    func channelWritabilityChanged(context:ChannelHandlerContext)
    {
        if  context.channel.isWritable
        {
            self.partner?.partnerBecameWritable()
        }
    }

    func read(context:ChannelHandlerContext)
    {
        if  case true? = self.partner?.partnerWritable
        {
            context.read()
        }
        else
        {
            self.readPending = true
        }
    }
}
