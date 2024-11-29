import _AsyncChannel
import Atomics
import HTTP
import IP
import IP_NIOCore
import NIOCore
import NIOHPACK
import NIOHTTP1
import NIOHTTP2
import NIOPosix
import NIOSSL
import URI

extension HTTP
{
    public
    protocol Server:Sendable
    {
        associatedtype StreamedRequest:HTTP.ServerStreamedRequest

        /// Checks whether the server should allow the request to proceed with an upload.
        /// Returns nil if the server should accept the upload, or an error response to send
        /// if the uploader lacks permissions.
        func clearance(for request:StreamedRequest) async throws -> HTTP.ServerResponse?

        func response(for request:StreamedRequest,
            with body:__owned [UInt8]) async throws -> HTTP.ServerResponse

        func get(
            request:ServerRequest,
            headers:HPACKHeaders) async throws -> HTTP.ServerResponse
        func get(
            request:ServerRequest,
            headers:HTTPHeaders) async throws -> HTTP.ServerResponse

        func post(
            request:ServerRequest,
            headers:HPACKHeaders,
            body:[UInt8]) async throws -> HTTP.ServerResponse

        func post(
            request:ServerRequest,
            headers:HTTPHeaders,
            body:[UInt8]) async throws -> HTTP.ServerResponse

        func log(event:ServerEvent, ip origin:ServerRequest.Origin?)
    }
}
extension HTTP.Server
{
    /// Inefficiently converts the headers to equivalent HPACK headers, and calls the witness
    /// for ``get(request:headers:) [4VK5G]``.
    ///
    /// Servers that expect to handle a lot of HTTP/1.1 GET requests should override this with
    /// a more efficient implementation.
    @inlinable public
    func get(
        request:HTTP.ServerRequest,
        headers:HTTPHeaders) async throws -> HTTP.ServerResponse
    {
        try await self.get(request: request, headers: .init(httpHeaders: headers))
    }

    /// Inefficiently converts the headers to equivalent HPACK headers, and calls the witness
    /// for ``post(request:headers:body:) [541MX]``.
    ///
    /// Servers that expect to handle a lot of HTTP/1.1 POST requests should override this with
    /// a more efficient implementation.
    @inlinable public
    func post(
        request:HTTP.ServerRequest,
        headers:HTTPHeaders,
        body:[UInt8]) async throws -> HTTP.ServerResponse
    {
        try await self.post(request: request, headers: .init(httpHeaders: headers), body: body)
    }
}

extension HTTP.Server
{
    public
    func serve<Authority>(
        from binding:(address:String, port:Int),
        as authority:Authority,
        on threads:MultiThreadedEventLoopGroup,
        policy:(any HTTP.ServerPolicy)? = nil) async throws
        where Authority:HTTP.ServerAuthority
    {
        let bootstrap:ServerBootstrap = .init(group: threads)
            .serverChannelOption(ChannelOptions.backlog, value: 256)
            .serverChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .childChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 1)

        var listener:NIOAsyncChannel<EventLoopFuture<
            NIONegotiatedHTTPVersion<
                NIOAsyncChannel<
                    HTTPPart<HTTPRequestHead, ByteBuffer>,
                    HTTPPart<HTTPResponseHead, ByteBuffer>>,
                (any Channel, NIOHTTP2Handler.AsyncStreamMultiplexer<HTTP.Stream>)>>, Never>

        if  case let context as NIOSSLContext = authority.context
        {
            listener = try await bootstrap.bind(
                host: binding.address,
                port: binding.port)
            {
                (channel:any Channel) in

                channel.pipeline.addHandler(NIOSSLServerHandler.init(context: context))
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
                                wrappingChannelSynchronously: connection,
                                configuration: .init())
                        }
                    }
                        http2ConnectionInitializer:
                    {
                        (connection:any Channel) in

                        connection.eventLoop.makeCompletedFuture { connection }
                    }
                        http2StreamInitializer:
                    {
                        (stream:any Channel) in

                        stream.eventLoop.makeCompletedFuture
                        {
                            guard
                            let id:HTTP2StreamID = try stream.syncOptions?.getOption(
                                HTTP2StreamChannelOptions.streamID)
                            else
                            {
                                throw HTTP.StreamIdentifierError.missing
                            }

                            return .init(frames: try .init(
                                    wrappingChannelSynchronously: stream,
                                    configuration: .init()),
                                id: id)
                        }
                    }
                }
            }
        }
        else
        {
            listener = try await bootstrap.bind(
                host: binding.address,
                port: binding.port)
            {
                (connection:any Channel) in

                connection.eventLoop.makeCompletedFuture
                {
                    let decoder:HTTPRequestDecoder = .init(leftOverBytesStrategy: .dropBytes)
                    let handlers:[any ChannelHandler] = [
                        HTTPResponseEncoder.init(configuration: .init()),
                        ByteToMessageHandler.init(decoder),
                        HTTP.OutboundShimHandler.init()
                    ]

                    try connection.pipeline.syncOperations.addHandlers(handlers)

                    let channel:NIOAsyncChannel<
                        HTTPPart<HTTPRequestHead, ByteBuffer>,
                        HTTPPart<HTTPResponseHead, ByteBuffer>> = try .init(
                        wrappingChannelSynchronously: connection,
                        configuration: .init())

                    return connection.eventLoop.makeSucceededFuture(.http1_1(channel))
                }
            }
        }

        Log[.debug] = "bound to \(binding.address):\(binding.port)"

        try await listener.executeThenClose
        {
            try await $0.iterate(concurrently: 60)
            {
                do
                {
                    let firewall:IP.Firewall? = policy?.load()

                    switch try await $0.get()
                    {
                    case .http1_1(let connection):
                        guard
                        let address:SocketAddress = connection.channel.remoteAddress,
                        let ip:IP.V6 = .init(address)
                        else
                        {
                            // What to do here?
                            try await connection.channel.close()
                            return
                        }

                        let origin:HTTP.ServerRequest.Origin = .lookup(ip: ip, in: firewall)

                        handler:
                        do
                        {
                            try await self.handle(connection: connection,
                                origin: origin,
                                as: Authority.self)
                        }
                        catch NIOSSLError.uncleanShutdown
                        {
                        }
                        catch let error
                        {
                            if  case let error as IOError = error, error.errnoCode == 104
                            {
                                //  Ignore connection reset by peer.
                                break handler
                            }

                            self.log(event: .http1(error), ip: origin)
                        }

                        try await connection.channel.close()

                    case .http2((let channel, let streams)):
                        guard
                        let address:SocketAddress = channel.remoteAddress,
                        let ip:IP.V6 = .init(address)
                        else
                        {
                            // What to do here?
                            try await channel.close()
                            return
                        }

                        let origin:HTTP.ServerRequest.Origin = .lookup(ip: ip, in: firewall)

                        do
                        {
                            try await self.handle(connection: channel,
                                streams: streams.inbound,
                                origin: origin,
                                as: Authority.self)
                        }
                        catch let error
                        {
                            self.log(event: .http2(error), ip: origin)
                        }

                        try await channel.close()
                    }
                }
                //  Normal and expected.
                //  https://forums.swift.org/t/what-nio-http-2-errors-can-be-safely-ignored/68182/2
                catch   ChannelError.alreadyClosed,
                        ChannelError.outputClosed,
                        NIOSSLError.uncleanShutdown
                {
                }
                catch let error
                {
                    self.log(event: .tcp(error), ip: nil)
                }
            }
        }
    }
}
extension HTTP.Server
{
    /// Handles an HTTP/1.1 connection.
    private
    func handle<Authority>(
        connection:NIOAsyncChannel<
            HTTPPart<HTTPRequestHead, ByteBuffer>,
            HTTPPart<HTTPResponseHead, ByteBuffer>>,
        origin:HTTP.ServerRequest.Origin,
        as _:Authority.Type) async throws where Authority:HTTP.ServerAuthority
    {
        try await connection.executeThenClose
        {
            (
                remote:NIOAsyncChannelInboundStream<HTTPPart<HTTPRequestHead, ByteBuffer>>,
                writer:NIOAsyncChannelOutboundWriter<HTTPPart<HTTPResponseHead, ByteBuffer>>
            )   in

            let inbound:AsyncThrowingChannel<
                HTTPPart<HTTPRequestHead, ByteBuffer>, any Error> = .init()

            async
            let _:Void = remote.forward(to: inbound) { $0 }
            async
            let _:Void =
            {
                try await Task.sleep(for: .seconds(15))
                inbound.finish()
            } ()

            var parts:AsyncThrowingChannel<HTTPPart<HTTPRequestHead, ByteBuffer>,
                any Error>.Iterator = inbound.makeAsyncIterator()

            while let part:HTTPPart<HTTPRequestHead, ByteBuffer> = try await parts.next()
            {
                guard case .head(let part) = part
                else
                {
                    continue
                }

                var message:HTTP.ServerMessage<Authority, HTTPHeaders>
                do
                {
                    message = .init(
                        response: try await self.respond(to: part,
                            inbound: &parts,
                            origin: origin,
                            as: Authority.self),
                        using: connection.channel.allocator)
                }
                catch let error
                {
                    self.log(event: .application(error), ip: origin)

                    message = .init(redacting: error,
                        using: connection.channel.allocator)
                }

                message.headers.add(name: "connection", value: "close")

                try await writer.send(message)

                guard part.isKeepAlive
                else
                {
                    return
                }

                // if  let service:IP.Service
                // {
                //     Log[.debug] = "(HTTP/1) client '\(service)' sent keep-alive"
                // }
            }
        }
    }

    private
    func respond<Authority>(to h1:HTTPRequestHead,
        inbound:inout AsyncThrowingChannel<
            HTTPPart<HTTPRequestHead, ByteBuffer>, any Error>.Iterator,
        origin:HTTP.ServerRequest.Origin,
        as _:Authority.Type) async throws -> HTTP.ServerResponse
        where Authority:HTTP.ServerAuthority
    {
        guard let uri:URI = .init(h1.uri)
        else
        {
            return .resource("Malformed URI\n", status: 400)
        }

        switch h1.method
        {
        case .HEAD:
            fallthrough

        case .GET:
            return try await self.get(
                request: .init(origin: origin, uri: uri),
                headers: h1.headers)

        case .PUT:
            guard
            let length:String = h1.headers["content-length"].first,
            let length:Int = .init(length)
            else
            {
                return .resource("Content length required\n", status: 411)
            }

            guard
            let request:StreamedRequest = .init(put: uri, headers: h1.headers)
            else
            {
                return .resource("Malformed request\n", status: 400)
            }

            if  let failure:HTTP.ServerResponse = try await self.clearance(for: request)
            {
                return failure
            }

            guard
            let body:[UInt8] = try await inbound.accumulateBuffers(length: length)
            else
            {
                return .resource("Content length does not match payload\n", status: 413)
            }

            return try await self.response(for: request, with: body)

        case .POST:
            guard
            let length:String = h1.headers["content-length"].first,
            let length:Int = .init(length)
            else
            {
                return .resource("Content length required\n", status: 411)
            }

            if  length > 1_000_000
            {
                return .resource("Content too large\n", status: 413)
            }

            guard
            let body:[UInt8] = try await inbound.accumulateBuffers(length: length)
            else
            {
                return .resource("Content length does not match payload\n", status: 400)
            }

            return try await self.post(
                request: .init(origin: origin, uri: uri),
                headers: h1.headers,
                body: body)

        default:
            return .resource("Method requires HTTP/2\n", status: 505)
        }
    }
}
extension HTTP.Server
{
    /// Handles an HTTP/2 connection.
    private
    func handle<Authority>(
        connection:any Channel,
        streams:NIOHTTP2AsyncSequence<HTTP.Stream>,
        origin:HTTP.ServerRequest.Origin,
        as _:Authority.Type) async throws where Authority:HTTP.ServerAuthority
    {
        //  I am not sure why the sequence of streams has no backpressure. Out of an abundance
        //  of caution, there is a hard limit of 128 buffered streams. A sane peer should never
        //  come anywhere near this limit.
        let (events, consumer):
        (
            AsyncThrowingStream<HTTP.StreamEvent, any Error>,
            AsyncThrowingStream<HTTP.StreamEvent, any Error>.Continuation
        ) = AsyncThrowingStream<HTTP.StreamEvent, any Error>.makeStream(
            bufferingPolicy: .bufferingOldest(128))

        //  We *should* terminate the stream on all exit paths out of this subtask, as this
        //  enables us to return early if the peer closes the connection. But if for some
        //  reason we don’t, the `quiesce` event will also lead us out of the function.
        async
        let _:Void = streams.forward(to: consumer) { .inbound($0) }
        async
        let _:Void =
        {
            //  This will throw if the peer closes the connection, or some network error caused
            //  us to exit the function. Either way, there would no longer be any need to emit
            //  the `quiesce` event.
            try await Task.sleep(for: .seconds(10))
            //  Why emit a `quiesce` event? Because we want to distinguish between the peer
            //  closing the connection and us closing the connection due to timeout. This
            //  prevents us from trying to send a `GOAWAY` frame to a peer who is already gone.
            consumer.yield(.quiesce)
        } ()

        var last:HTTP2StreamID? = nil
        for try await event:HTTP.StreamEvent in events
        {
            switch event
            {
            case .inbound(let stream):
                //  A misbehaving peer might send us non-monotonic stream identifiers.
                //  There is no harm in ignoring them, but we might as well `max` them.
                last = last.map { max($0, stream.id) } ?? stream.id

                try await stream.frames.executeThenClose
                {
                    (
                        inbound:NIOAsyncChannelInboundStream<HTTP2Frame.FramePayload>,
                        outbound:NIOAsyncChannelOutboundWriter<HTTP2Frame.FramePayload>
                    )   in

                    let request:Task<HTTP.ServerResponse, any Error> = .init
                    {
                        try await self.respond(to: inbound, origin: origin, as: Authority.self)
                    }
                    stream.frames.channel.closeFuture.whenComplete
                    {
                        _ in request.cancel()
                    }

                    let message:HTTP.ServerMessage<Authority, HPACKHeaders>
                    do
                    {
                        message = .init(response: try await request.value,
                            using: stream.frames.channel.allocator)
                    }
                    catch is CancellationError
                    {
                        return
                    }
                    catch let error
                    {
                        self.log(event: .application(error), ip: origin)

                        message = .init(
                            redacting: error,
                            using: stream.frames.channel.allocator)
                    }

                    try await outbound.send(message)
                }

            case .quiesce:
                if  let last:HTTP2StreamID
                {
                    //  Formally, we should first be sending a `GOAWAY` frame containing
                    //  `maxID`. But Firefox doesn’t seem to treat it any differently from
                    //  simply dropping the connection; it is the second `GOAWAY` frame that
                    //  determines the retry behavior.
                    connection.write(HTTP2Frame.init(streamID: 0, payload: .goAway(
                            lastStreamID: .maxID,
                            errorCode: .noError,
                            opaqueData: nil)),
                        promise: nil)
                    //  If we do not send this frame, Firefox will perceive an unclean
                    //  shutdown and will not retry any cancelled requests.
                    connection.write(HTTP2Frame.init(streamID: 0, payload: .goAway(
                            lastStreamID: last,
                            errorCode: .noError,
                            opaqueData: nil)),
                        promise: nil)
                }
                else
                {
                    self.log(event: .http2(HTTP.ActivityTimeoutError.connection), ip: origin)
                }

                //  There doesn’t seem to be any benefit from sticking around after sending
                //  the second `GOAWAY` frame. Notably, Firefox will not close the connection
                //  for us. And per the semantics of `GOAWAY`, we have not committed to handling
                //  any subsequent streams.
                consumer.finish()
            }
        }
    }

    private
    func respond<Authority>(to h2:NIOAsyncChannelInboundStream<HTTP2Frame.FramePayload>,
        origin:HTTP.ServerRequest.Origin,
        as _:Authority.Type) async throws -> HTTP.ServerResponse
        where Authority:HTTP.ServerAuthority
    {
        /// We should use a channel and not just a stream, in order to preserve backpressure.
        let frames:AsyncThrowingChannel<HTTP2Frame.FramePayload?, any Error> = .init()

        /// Launch the task that simply forwards the output of the
        /// ``NIOAsyncChannelInboundStream`` to the combined stream. This seems comically
        /// inefficient, but it is needed in order to add timeout events to an HTTP/2 stream.
        async
        let _:Void = h2.forward(to: frames) { $0 }
        /// Launch the task that emits a timeout event after 5 seconds. This doesn’t terminate
        /// the stream because we want to be able to ignore the timeout events after the peer
        /// completes authentication, if applicable. This allows us to accept long-running
        /// uploads from trusted peers.
        async
        let _:Void =
        {
            try await Task.sleep(for: .seconds(5))
            await frames.send(nil)
        } ()

        var inbound:AsyncThrowingChannel<HTTP2Frame.FramePayload?, any Error>.Iterator
        var headers:HPACKHeaders? = nil

        /// Wait for the `HEADERS` frame, which initiates the application-level request. This
        /// frame contains cookies, so after we get it, we will know if we can ignore timeouts.
        waiting:
        do
        {
            inbound = frames.makeAsyncIterator()

            switch try await inbound.next()
            {
            case .headers(let payload)??:
                headers = payload.headers

            case _??:
                continue waiting

            case nil, nil?:
                self.log(event: .http2(HTTP.ActivityTimeoutError.stream), ip: origin)
                return .resource("Time limit exceeded", status: 408)
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

        guard
        let path:URI = .init(path)
        else
        {
            return .resource("Malformed URI", status: 400)
        }

        switch method
        {
        case "HEAD":
            // return .resource("Method not allowed", status: 405)
            fallthrough

        case "GET":
            return try await self.get(
                request: .init(origin: origin, uri: path),
                headers: headers)

        case "PUT":
            guard
            let length:String = headers["content-length"].first,
            let length:Int = .init(length)
            else
            {
                return .resource("Content length required", status: 411)
            }

            guard
            let request:StreamedRequest = .init(put: path, headers: headers)
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

            while let payload:HTTP2Frame.FramePayload? = try await inbound.next()
            {
                //  We could care less about timeout events here, as we have already determined
                //  the request originates from a trusted source.
                guard case .data(let payload)? = payload
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
            if  length > 0
            {
                body.reserveCapacity(length)

                while let payload:HTTP2Frame.FramePayload? = try await inbound.next()
                {
                    guard
                    let payload:HTTP2Frame.FramePayload
                    else
                    {
                        return .resource("Time limit exceeded", status: 408)
                    }

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
            }

            return try await self.post(
                request: .init(origin: origin, uri: path),
                headers: headers,
                body: body)

        case _:
            return .forbidden("Forbidden")
        }
    }
}
