import HTTP
import MD5
import NIOCore
import NIOHTTP1

final
class ServerInterfaceHandler<Authority, Server>
    where Authority:ServerAuthority, Server:HTTPServerDelegate
{
    private
    var request:(head:HTTPRequestHead, stream:[UInt8])?,
        responding:Bool,
        receiving:Bool
    private
    let address:SocketAddress?
    private
    let server:Server

    init(address:SocketAddress?, server:Server)
    {
        self.request = nil
        self.receiving = false
        self.responding = false

        self.address = address
        self.server = server
    }
}
extension ServerInterfaceHandler:ChannelInboundHandler, RemovableChannelHandler
{
    typealias InboundIn = HTTPServerRequestPart
    typealias OutboundOut = HTTPServerResponsePart

    func userInboundEventTriggered(context:ChannelHandlerContext, event:Any)
    {
        if  case .inputClosed? = event as? ChannelEvent
        {
            self.receiving = false
        }
        else
        {
            context.fireUserInboundEventTriggered(event)
            return
        }
        guard self.responding
        else
        {
            context.close(promise: nil)
            return
        }
    }

    func channelReadComplete(context:ChannelHandlerContext)
    {
        context.flush()
    }

    func channelRead(context:ChannelHandlerContext, data:NIOAny)
    {
        switch self.unwrapInboundIn(data)
        {
        case .head(let head):
            self.receiving = head.isKeepAlive
            switch head.method
            {
            case .GET:
                self.request = nil

                if  let operation:Server.Operation = .init(get: head.uri,
                        address: self.address,
                        headers: head.headers)
                {
                    self.server.submit(operation, promise: self.accept(context: context))
                }
                else
                {
                    self.send(message: .init(status: .badRequest), context: context)
                }

            case .POST, .PUT:
                self.request = (head, .init())

            case _:
                self.send(message: .init(status: .methodNotAllowed), context: context)
            }

        case .body(let buffer):
            guard case (let head, var body)? = self.request
            else
            {
                break
            }

            self.request = nil

            //  32 MB size limit
            if  1 << 25 < body.count + buffer.readableBytes
            {
                self.send(message: .init(status: .payloadTooLarge), context: context)
            }
            else
            {
                //  is this slower than accumulating into another ByteBuffer, and then
                //  doing an explicit copy into a `[UInt8]`?
                //
                //  alternatively, can consumers adopt the neutral ABI provided by
                //  ``ByteBufferView.withUnsafeReadableBytesWithStorageManagement(_:)``?
                body.append(contentsOf: buffer.readableBytesView)
                self.request = (head, body)
            }

        case .end(_):
            guard case let (head, body)? = self.request
            else
            {
                // already responded
                break
            }

            self.request = nil

            let operation:Server.Operation?

            switch head.method
            {
            case .POST:
                operation = .init(post: head.uri,
                    address: self.address,
                    headers: head.headers,
                    body: body)

            case .PUT:
                operation = .init(put: head.uri,
                    address: self.address,
                    headers: head.headers,
                    body: body)

            case _:
                fatalError("unreachable: collected buffers for method \(head.method)!")
            }

            if  let operation:Server.Operation
            {
                self.server.submit(operation, promise: self.accept(context: context))
            }
            else
            {
                self.send(message: .init(status: .badRequest), context: context)
            }
        }
    }
}
extension ServerInterfaceHandler
{
    private
    func accept(context:ChannelHandlerContext) -> EventLoopPromise<ServerResponse>
    {
        let promise:EventLoopPromise<ServerResponse> = context.eventLoop.makePromise(
            of: ServerResponse.self)

        promise.futureResult.whenComplete
        {
            switch $0
            {
            case .success(let response):
                self.send(
                    message: .init(response: response, using: context.channel.allocator),
                    context: context)

            case .failure(let error):
                self.send(
                    message: .init(redacting: error, using: context.channel.allocator),
                    context: context)
            }
        }
        return promise
    }

    private
    func send(message:ServerMessage<Authority>, context:ChannelHandlerContext)
    {
        self.responding = true

        let sent:EventLoopPromise<Void> = context.eventLoop.makePromise(of: Void.self)
            sent.futureResult.whenComplete
        {
            _ in
            self.responding = false
            if !self.receiving
            {
                context.channel.close(promise: nil)
            }
        }

        context.write(self.wrapOutboundOut(.head(.init(version: .http1_1,
                status: message.status,
                headers: message.headers))),
            promise: nil)

        if  let body:ByteBuffer = message.body
        {
            context.write(self.wrapOutboundOut(.body(IOData.byteBuffer(body))),
                promise: nil)
        }

        context.writeAndFlush(self.wrapOutboundOut(.end(nil)),
            promise: sent)
    }
}
