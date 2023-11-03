import HTTP
import IP
import NIOCore
import NIOPosix
import NIOHTTP1
import NIOHPACK
import NIOHTTP2
import NIOSSL

extension NIOHTTP2Handler.AsyncStreamMultiplexer:@unchecked Sendable
{
}
extension NIONegotiatedHTTPVersion:@unchecked Sendable
{
}

extension HTTP
{
    public
    typealias Server = _HTTPServer
}

@available(*, deprecated, renamed: "HTTP.Server")
public
typealias HTTPServer = HTTP.Server

/// The name of this protocol is ``HTTP.Server``.
public
protocol _HTTPServer:Sendable
{
    associatedtype StreamedRequest:HTTP.ServerStreamedRequest
    associatedtype IntegralRequest:HTTP.ServerIntegralRequest

    /// Checks whether the server should allow the request to proceed with an upload.
    /// Returns nil if the server should accept the upload, or an error response to send
    /// if the uploader lacks permissions.
    func clearance(for request:StreamedRequest) async throws -> HTTP.ServerResponse?

    func response(for request:StreamedRequest,
        with body:[UInt8]) async throws -> HTTP.ServerResponse

    func response(for request:IntegralRequest) async throws -> HTTP.ServerResponse
}

extension HTTP.Server
{
    public
    func serve<Authority>(
        from binding:(address:String, port:Int),
        as authority:Authority,
        on threads:MultiThreadedEventLoopGroup) async throws
        where Authority:ServerAuthority
    {
        let bootstrap:ServerBootstrap = .init(group: threads)
            .serverChannelOption(ChannelOptions.backlog, value: 256)
            .serverChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .childChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 1)

        let listener:NIOAsyncChannel = try await bootstrap.bind(
            host: binding.address,
            port: binding.port)
        {
            (channel:any Channel) in

            channel.pipeline.addHandler(NIOSSLServerHandler.init(context: authority.tls))
                .flatMap
            {
                channel.configureAsyncHTTPServerPipeline
                {
                    (connection:any Channel) in

                    connection.eventLoop.makeCompletedFuture
                    {
                        try connection.pipeline.syncOperations.addHandler(
                            HTTP.OutboundShimHandler.init())

                        return try NIOAsyncChannel<
                            HTTPPart<HTTPRequestHead, ByteBuffer>,
                            HTTPPart<HTTPResponseHead, ByteBuffer>>.init(
                            synchronouslyWrapping: connection,
                            configuration: .init())
                    }
                }
                    http2ConnectionInitializer:
                {
                    (connection:any Channel) in

                    connection.eventLoop.makeCompletedFuture
                    {
                        try NIOAsyncChannel<HTTP2Frame, HTTP2Frame>(
                            synchronouslyWrapping: connection,
                            configuration: .init())
                    }
                }
                    http2StreamInitializer:
                {
                    (stream:any Channel) in

                    stream.eventLoop.makeCompletedFuture
                    {
                        try NIOAsyncChannel<
                            HTTP2Frame.FramePayload,
                            HTTP2Frame.FramePayload>.init(
                            synchronouslyWrapping: stream,
                            configuration: .init())
                    }
                }
            }
        }

        Log[.debug] = "bound to \(binding.address):\(binding.port)"

        await withTaskGroup(of: Void.self)
        {
            (tasks:inout TaskGroup<Void>) in

            await tasks.iterate(listener.inbound, width: 60)
            {
                do
                {
                    switch try await $0.get()
                    {
                    case .http1_1(let connection):
                        guard
                        let address:SocketAddress = connection.channel.remoteAddress,
                        let address:IP.V6 = .init(address)
                        else
                        {
                            // What to do here?
                            try await connection.channel.close()
                            return
                        }

                        /// Reap connections after 3 seconds.
                        async
                        let _:Void =
                        {
                            try await Task.sleep(for: .milliseconds(3000))
                            try await connection.channel.close()
                        }()

                        let message:HTTP.ServerMessage<Authority, HTTPHeaders>
                        do
                        {
                            message = .init(
                                response: try await self.respond(toH1: connection,
                                    from: address,
                                    as: Authority.self),
                                using: connection.channel.allocator)
                        }
                        catch let error
                        {
                            message = .init(
                                redacting: error,
                                using: connection.channel.allocator)
                        }

                        try await connection.outbound.finish(with: message)
                        try await connection.channel.close()

                    case .http2((let connection, let streams)):
                        guard
                        let address:SocketAddress = connection.channel.remoteAddress,
                        let address:IP.V6 = .init(address)
                        else
                        {
                            // What to do here?
                            try await connection.channel.close()
                            return
                        }

                        /// Reap connections after one second of inactivity.
                        let cop:TimeCop = .init()
                        async
                        let _:Void =
                        {
                            (cop:borrowing TimeCop) in

                            try await cop.start(interval: .milliseconds(1000))
                            try await connection.channel.close()

                        } (cop)

                        for try await stream:NIOAsyncChannel<
                            HTTP2Frame.FramePayload,
                            HTTP2Frame.FramePayload> in streams.inbound
                        {
                            let message:HTTP.ServerMessage<Authority, HPACKHeaders>
                            do
                            {
                                message = .init(
                                    response: try await self.respond(toH2: stream,
                                        from: address,
                                        with: cop,
                                        as: Authority.self),
                                    using: stream.channel.allocator)
                            }
                            catch let error
                            {
                                message = .init(
                                    redacting: error,
                                    using: stream.channel.allocator)
                            }

                            cop.reset()

                            try await stream.outbound.finish(with: message)
                        }
                    }
                }
                //  https://forums.swift.org/t/what-nio-http-2-errors-can-be-safely-ignored/68182/2
                catch NIOSSLError.uncleanShutdown
                {
                }
                catch let error
                {
                    Log[.error] = "\(error)"
                }
            }
                else:
            {
                Log[.error] = "\($0)"
            }
        }
    }

    private
    func respond<Authority>(
        toH1 stream:NIOAsyncChannel<
            HTTPPart<HTTPRequestHead, ByteBuffer>,
            HTTPPart<HTTPResponseHead, ByteBuffer>>,
        from address:IP.V6,
        as _:Authority.Type) async throws -> HTTP.ServerResponse
        where Authority:ServerAuthority
    {
        for try await part:HTTPPart<HTTPRequestHead, ByteBuffer> in stream.inbound
        {
            guard
            case .head(let head) = part,
            case .GET = head.method
            else
            {
                break
            }

            if  let request:IntegralRequest = .init(get: head.uri,
                    headers: head.headers,
                    address: address)
            {
                return try await self.response(for: request)
            }
            else
            {
                return .resource("Malformed request", status: 400)
            }
        }

        return .resource("Method requires HTTP/2", status: 505)
    }

    private
    func respond<Authority>(
        toH2 stream:NIOAsyncChannel<HTTP2Frame.FramePayload, HTTP2Frame.FramePayload>,
        from address:IP.V6,
        with cop:borrowing TimeCop,
        as _:Authority.Type) async throws -> HTTP.ServerResponse
        where Authority:ServerAuthority
    {
        var inbound:NIOAsyncChannelInboundStream<HTTP2Frame.FramePayload>.AsyncIterator =
            stream.inbound.makeAsyncIterator()

        var headers:HPACKHeaders? = nil
        while let payload:HTTP2Frame.FramePayload = try await inbound.next()
        {
            cop.reset()

            if  case .headers(let payload) = payload
            {
                headers = payload.headers
                break
            }
        }

        guard
        let headers:HPACKHeaders,
        let method:String = headers[":method"].first,
        let path:String = headers[":path"].first
        else
        {
            return .resource("Missing headers", status: 400)
        }

        switch method
        {
        case "GET":
            if  let request:IntegralRequest = .init(get: path,
                    headers: headers,
                    address: address)
            {
                return try await self.response(for: request)
            }
            else
            {
                return .resource("Malformed request", status: 400)
            }

        case "PUT":
            guard
            let length:String = headers["content-length"].first,
            let length:Int = .init(length)
            else
            {
                return .resource("Content length required", status: 411)
            }

            guard
            let request:StreamedRequest = .init(put: path,
                headers: headers,
                address: address)
            else
            {
                return .resource("Malformed request", status: 400)
            }

            if  let failure:HTTP.ServerResponse = try await self.clearance(for: request)
            {
                return failure
            }

            var body:[UInt8] = []
                body.reserveCapacity(length)

            while let payload:HTTP2Frame.FramePayload = try await inbound.next()
            {
                cop.reset()

                guard case .data(let payload) = payload
                else
                {
                    continue
                }

                if  case .byteBuffer(let payload) = payload.data
                {
                    payload.withUnsafeReadableBytes { body += $0 }
                }

                //  Why can’t NIO do this for us?
                if  payload.endStream
                {
                    break
                }
            }

            return try await self.response(for: request, with: body)

        case "POST":
            guard
            let length:String = headers["content-length"].first,
            let length:Int = .init(length)
            else
            {
                return .resource("Content length required", status: 411)
            }

            if  length > 1_000_000
            {
                return .resource("Content too large", status: 413)
            }

            var body:[UInt8] = []
                body.reserveCapacity(length)

            while let payload:HTTP2Frame.FramePayload = try await inbound.next()
            {
                cop.reset()

                guard
                case .data(let payload) = payload,
                case .byteBuffer(let buffer) = payload.data
                else
                {
                    continue
                }

                if  buffer.readableBytes <= length - body.count
                {
                    buffer.withUnsafeReadableBytes { body += $0 }
                }
                else
                {
                    return .resource("Content too large", status: 413)
                }

                //  Why can’t NIO do this for us?
                if  payload.endStream
                {
                    break
                }
            }

            if  let request:IntegralRequest = .init(post: path,
                    headers: headers,
                    address: address,
                    body: body)
            {
                return try await self.response(for: request)
            }
            else
            {
                return .resource("Malformed request", status: 400)
            }

        case _:
            return .forbidden("Forbidden")
        }
    }
}
