import Atomics
import HTTP
import IP
import MD5
import NIOCore
import NIOHTTP1

final
class ServerInterfaceHandler<Authority, Server>
    where Authority:ServerAuthority, Server:HTTPServerDelegate
{
    private
    var request:(head:HTTPRequestHead, stream:[UInt8])?
    private
    let address:IP.Address?
    private
    let server:Server

    init(address:SocketAddress?, server:Server)
    {
        self.request = nil

        self.address = address.map(IP.Address.init(_:)) ?? nil
        self.server = server
    }
}
extension ServerInterfaceHandler:ChannelInboundHandler, RemovableChannelHandler
{
    typealias InboundIn = HTTPServerRequestPart
    typealias OutboundOut = HTTPServerResponsePart

    func channelReadComplete(context:ChannelHandlerContext)
    {
        context.flush()
    }

    func channelRead(context:ChannelHandlerContext, data:NIOAny)
    {
        switch self.unwrapInboundIn(data)
        {
        case .head(let head):
            switch head.method
            {
            case .GET:
                self.request = nil

                guard
                let operation:Server.Operation = .init(get: head.uri,
                    address: self.address,
                    headers: head.headers)
                else
                {
                    self.send(message: .init(status: .badRequest), context: context)
                    break
                }
                if  let promise:EventLoopPromise<ServerResponse> = self.accept(context: context)
                {
                    self.server.submit(operation, promise: promise)
                }
                else
                {
                    self.reject(context: context)
                }

            case .POST, .PUT:
                print("""
                    received POST/PUT request from \(self.address?.description ?? "unknown")
                    """)
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

            guard
            let operation:Server.Operation
            else
            {
                self.send(message: .init(status: .badRequest), context: context)
                break
            }
            if  let promise:EventLoopPromise<ServerResponse> = self.accept(context: context)
            {
                self.server.submit(operation, promise: promise)
            }
            else
            {
                self.reject(context: context)
            }

        }
    }
}
extension ServerInterfaceHandler
{
    private
    func accept(context:ChannelHandlerContext) -> EventLoopPromise<ServerResponse>?
    {
        let requests:Int = self.server.meter.requests.wrappingIncrementThenLoad(
            ordering: .relaxed)

        guard requests < 16
        else
        {
            self.server.meter.requests.wrappingDecrement(ordering: .relaxed)
            return nil
        }

        let promise:EventLoopPromise<ServerResponse> = context.eventLoop.makePromise(
            of: ServerResponse.self)

        promise.futureResult.whenComplete
        {
            self.server.meter.requests.wrappingDecrement(ordering: .relaxed)

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
    func reject(context:ChannelHandlerContext)
    {
        print("rejected request from \(self.address as Any)!")
        self.send(message: .init(
                response: .unavailable("Too many requests!"),
                using: context.channel.allocator),
            context: context)
    }

    private
    func send(message:ServerMessage<Authority>, context:ChannelHandlerContext)
    {
        let sent:EventLoopPromise<Void> = context.eventLoop.makePromise(of: Void.self)
            sent.futureResult.whenComplete
        {
            _ in context.channel.close(promise: nil)
        }

        context.write(self.wrapOutboundOut(.head(.init(version: .http2,
                status: message.status,
                headers: message.headers))),
            promise: nil)

        if  let body:ByteBuffer = message.body
        {
            context.write(self.wrapOutboundOut(.body(IOData.byteBuffer(body))),
                promise: nil)
        }

        context.writeAndFlush(self.wrapOutboundOut(.end(nil)), promise: sent)
    }
}
