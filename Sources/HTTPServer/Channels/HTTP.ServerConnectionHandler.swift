import HTTP
import NIOCore

extension HTTP
{
    final
    class ServerConnectionHandler
    {
        private
        var connections:Int

        init()
        {
            self.connections = 0
        }
    }
}
extension HTTP.ServerConnectionHandler
{
    private static
    var capacity:Int { 50 }
}
extension HTTP.ServerConnectionHandler:ChannelInboundHandler
{
    typealias InboundOut = any Channel
    typealias InboundIn = any Channel

    func channelRead(context:ChannelHandlerContext, data:NIOAny)
    {
        defer
        {
            context.fireChannelRead(data)
        }

        let channel:any Channel = self.unwrapInboundIn(data)

        //  If we have room for more connections, enqueue another read.
        self.connections += 1
        if  self.connections < Self.capacity
        {
            context.read()
        }
        else
        {
            Log[.warning] = """
            Buffered connection due to capacity limit.
            """
        }

        channel.closeFuture.whenComplete
        {
            _ in

            //  Are we even on the right thread???
            if  context.eventLoop.inEventLoop
            {
                //  We now have room for at least one more connection,
                //  so enqueue a read.
                self.connections -= 1
                context.read()
                return
            }

            context.eventLoop.execute
            {
                self.connections -= 1
                context.read()
            }
        }
    }
}
extension HTTP.ServerConnectionHandler:ChannelOutboundHandler
{
    typealias OutboundIn = Never
    typealias OutboundOut = Never

    func read(context:ChannelHandlerContext)
    {
        //  Don’t bother buffering a pending read if we’re already at capacity,
        //  since the only way a slot can open up is if a connection closes, and
        //  that will trigger a read on its own.
        if  self.connections < Self.capacity
        {
            context.read()
        }
        else
        {
            Log[.warning] = """
            Buffered connection due to capacity limit.
            """
        }
    }
}
