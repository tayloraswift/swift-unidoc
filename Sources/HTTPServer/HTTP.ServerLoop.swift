import _AsyncChannel
import Atomics
import HTTP
import IP
import NIOCore
import NIOHPACK
import NIOHTTP1
import NIOHTTP2
import NIOPosix
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
    protocol ServerLoop:Sendable
    {
        associatedtype StreamedRequest:HTTP.ServerStreamedRequest
        associatedtype IntegralRequest:HTTP.ServerIntegralRequest

        /// Checks whether the server should allow the request to proceed with an upload.
        /// Returns nil if the server should accept the upload, or an error response to send
        /// if the uploader lacks permissions.
        func clearance(for request:StreamedRequest) async throws -> HTTP.ServerResponse?

        func response(for request:StreamedRequest,
            with body:consuming [UInt8]) async throws -> HTTP.ServerResponse

        func response(for request:IntegralRequest) async throws -> HTTP.ServerResponse
    }
}
extension HTTP.ServerLoop
{
    public
    func serve<Authority>(
        from binding:(address:String, port:Int),
        as authority:Authority,
        on threads:MultiThreadedEventLoopGroup,
        policy:(some HTTP.ServerPolicy)? = nil) async throws
        where Authority:ServerAuthority
    {
        let bootstrap:ServerBootstrap = .init(group: threads)
            .serverChannelOption(ChannelOptions.backlog, value: 256)
            .serverChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .childChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 1)

        let listener:
            NIOAsyncChannel<
                EventLoopFuture<NIONegotiatedHTTPVersion<
                    NIOAsyncChannel<
                        HTTPPart<HTTPRequestHead, ByteBuffer>,
                        HTTPPart<HTTPResponseHead, ByteBuffer>>,
                    (
                        any Channel,
                        NIOHTTP2Handler.AsyncStreamMultiplexer<HTTP.Stream>
                    )>>,
                Never> = try await bootstrap.bind(
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

        Log[.debug] = "bound to \(binding.address):\(binding.port)"

        try await listener.executeThenClose
        {
            try await $0.iterate(concurrently: 60)
            {
                do
                {
                    let policylist:IP.Policylist = policy?.load() ?? .init()

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

                        let service:IP.Service? = policylist[address]

                        do
                        {
                            try await self.handle(connection: connection,
                                address: address,
                                service: service,
                                as: Authority.self)
                        }
                        catch NIOSSLError.uncleanShutdown
                        {
                        }
                        catch let error as IOError
                        {
                            if  error.errnoCode != 104
                            {
                                Log[.error] = "(HTTP/1.1) \(error)"
                            }
                        }
                        catch let error
                        {
                            Log[.error] = "(HTTP/1.1) \(error)"
                        }

                        try await connection.channel.close()

                    case .http2((let channel, let streams)):
                        guard
                        let address:SocketAddress = channel.remoteAddress,
                        let address:IP.V6 = .init(address)
                        else
                        {
                            // What to do here?
                            try await channel.close()
                            return
                        }

                        let service:IP.Service? = policylist[address]

                        do
                        {
                            try await self.handle(connection: channel,
                                streams: streams.inbound,
                                address: address,
                                service: service,
                                as: Authority.self)
                        }
                        catch let error
                        {
                            Log[.error] = "(HTTP/2: \(address)) \(error)"
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
                    Log[.error] = "\(error)"
                }
            }
        }
    }
}
extension HTTP.ServerLoop
{
    /// Handles an HTTP/1.1 connection.
    private
    func handle<Authority>(
        connection:NIOAsyncChannel<
            HTTPPart<HTTPRequestHead, ByteBuffer>,
            HTTPPart<HTTPResponseHead, ByteBuffer>>,
        address:IP.V6,
        service:IP.Service?,
        as _:Authority.Type) async throws where Authority:ServerAuthority
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

            for try await case .head(let part) in inbound
            {
                var message:HTTP.ServerMessage<Authority, HTTPHeaders>
                do
                {
                    message = .init(
                        response: try await self.respond(to: part,
                            address: address,
                            service: service,
                            as: Authority.self),
                        using: connection.channel.allocator)
                }
                catch let error
                {
                    Log[.error] = "(application) \(error)"

                    message = .init(
                        redacting: error,
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
        address:IP.V6,
        service:IP.Service?,
        as _:Authority.Type) async throws -> HTTP.ServerResponse
        where Authority:ServerAuthority
    {
        switch h1.method
        {
        case .HEAD:
            // return .resource("Method not allowed", status: 405)
            fallthrough

        case .GET:
            if  let request:IntegralRequest = .init(get: h1.uri,
                    headers: h1.headers,
                    address: address,
                    service: service)
            {
                return try await self.response(for: request)
            }
            else
            {
                return .resource("Malformed request", status: 400)
            }

        default:
            return .resource("Method requires HTTP/2", status: 505)
        }
    }
}
extension HTTP.ServerLoop
{
    /// Handles an HTTP/2 connection.
    private
    func handle<Authority>(
        connection:any Channel,
        streams:NIOHTTP2AsyncSequence<HTTP.Stream>,
        address:IP.V6,
        service:IP.Service?,
        as _:Authority.Type) async throws where Authority:ServerAuthority
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
                        try await self.respond(to: inbound,
                                address: address,
                                service: service,
                                as: Authority.self)
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
                        Log[.error] = "(application: \(address)) \(error)"

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
                    Log[.warning] = """
                    (HTTP/2: \(address)) \
                    Connection timed out before peer initiated any streams.
                    """
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
        address:IP.V6,
        service:IP.Service?,
        as _:Authority.Type) async throws -> HTTP.ServerResponse
        where Authority:ServerAuthority
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
                Log[.error] = """
                (HTTP/2: \(address)) Stream timed out before peer sent any headers.
                """

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

        switch method
        {
        case "HEAD":
            // return .resource("Method not allowed", status: 405)
            fallthrough

        case "GET":
            if  let request:IntegralRequest = .init(get: path,
                    headers: headers,
                    address: address,
                    service: service)
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
                headers: headers)
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
                body.reserveCapacity(length)

            while let payload:HTTP2Frame.FramePayload? = try await inbound.next()
            {
                guard
                case .data(let payload)? = payload,
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
                    service: service,
                    body: /* consume */ body) // https://github.com/apple/swift/issues/71605
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
