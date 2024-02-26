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
    typealias ServerLoop = _HTTPServerLoop
}

@available(*, deprecated, renamed: "HTTP.ServerLoop")
public
typealias HTTPServer = HTTP.ServerLoop

/// The name of this protocol is ``HTTP.Server``.
public
protocol _HTTPServerLoop:Sendable
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

                        await self.handle(connection: connection,
                            address: address,
                            service: service,
                            as: Authority.self)

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

                        await self.handle(connection: channel,
                            streams: streams,
                            address: address,
                            service: service,
                            as: Authority.self)

                        try await channel.close()
                    }
                }
                //  Normal and expected.
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
    private
    func handle<Authority>(
        connection:NIOAsyncChannel<
            HTTPPart<HTTPRequestHead, ByteBuffer>,
            HTTPPart<HTTPResponseHead, ByteBuffer>>,
        address:IP.V6,
        service:IP.Service?,
        as _:Authority.Type) async where Authority:ServerAuthority
    {
        await withTaskGroup(of: HTTP.ServerMessage<Authority, HTTPHeaders>?.self)
        {
            (tasks:inout TaskGroup<HTTP.ServerMessage<Authority, HTTPHeaders>?>) in

            var completed:TaskGroup<HTTP.ServerMessage<Authority, HTTPHeaders>?>.Iterator =
                tasks.makeAsyncIterator()

            let cop:TimeCop = .init()

            tasks.addTask
            {
                try? await cop.start(beat: .milliseconds(1000))
                //  We must close the connection, otherwise we will continue to wait for
                //  the next inbound request fragment.
                connection.channel.close(promise: nil)
                return nil
            }

            defer
            {
                tasks.cancelAll()
            }

            do
            {
                try await connection.executeThenClose
                {
                    (
                        remote:NIOAsyncChannelInboundStream<
                            HTTPPart<HTTPRequestHead, ByteBuffer>>,
                        writer:NIOAsyncChannelOutboundWriter<
                            HTTPPart<HTTPResponseHead, ByteBuffer>>
                    )   in

                    for try await part:HTTPPart<HTTPRequestHead, ByteBuffer> in remote
                    {
                        guard
                        case .head(let part) = part
                        else
                        {
                            //  Ignore.
                            continue
                        }

                        tasks.addTask
                        {
                            do
                            {
                                return .init(
                                    response: try await self.respond(to: part,
                                        address: address,
                                        service: service,
                                        with: cop,
                                        as: Authority.self),
                                    using: connection.channel.allocator)
                            }
                            catch let error
                            {
                                Log[.error] = "(application) \(error)"

                                return .init(
                                    redacting: error,
                                    using: connection.channel.allocator)
                            }
                        }

                        //  If `cop.active` is false, then the other task has already begun
                        //  closing the connection.
                        guard
                        case let message?? = await completed.next()
                        else
                        {
                            return
                        }

                        try await cop.pause { try await writer.send(message) }

                        guard part.isKeepAlive
                        else
                        {
                            return
                        }
                    }
                }
            }
            //  https://forums.swift.org/t/what-nio-http-2-errors-can-be-safely-ignored/68182/2
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
        }
    }

    private
    func respond<Authority>(to h1:HTTPRequestHead,
        address:IP.V6,
        service:IP.Service?,
        with cop:borrowing TimeCop,
        as _:Authority.Type) async throws -> HTTP.ServerResponse
        where Authority:ServerAuthority
    {
        cop.reset()

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
                return try await cop.pause { try await self.response(for: request) }
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
    private
    func handle<Authority>(
        connection:any Channel,
        streams:NIOHTTP2Handler.AsyncStreamMultiplexer<HTTP.Stream>,
        address:IP.V6,
        service:IP.Service?,
        as _:Authority.Type) async where Authority:ServerAuthority
    {
        /// Do the ``AsyncStream`` ritual dance.
        var c:AsyncThrowingStream<HTTP.StreamEvent, any Error>.Continuation? = nil
        let s:AsyncThrowingStream<HTTP.StreamEvent, any Error> = .init { c = $0 }
        guard
        let c:AsyncThrowingStream<HTTP.StreamEvent, any Error>.Continuation
        else
        {
            fatalError("unreachable")
        }

        async
        let _:Void =
        {
            //  We *should* terminate the stream on all exit paths out of this subtask, as this
            //  enables us to return early if the peer closes the connection. But if for some
            //  reason we don’t, the `quiesce` event will also lead us out of the function.
            do
            {
                for try await stream:HTTP.Stream in $1
                {
                    c.yield(.inbound(stream))
                }
                $0.finish()
            }
            catch let error
            {
                $0.finish(throwing: error)
            }
        } (c, streams.inbound)

        async
        let _:Void =
        {
            //  This will throw if the peer closes the connection, or some network error caused
            //  us to exit the function. Either way, there would no longer be any need to emit
            //  the `quiesce` event.
            try await Task.sleep(for: .seconds(5))
            //  Why emit a `quiesce` event? Because we want to distinguish between the peer
            //  closing the connection and us closing the connection due to timeout. This
            //  prevents us from trying to send a `GOAWAY` frame to a peer who is already gone.
            $0.yield(.quiesce)
        } (c)

        do
        {
            var last:HTTP2StreamID? = nil
            for try await event:HTTP.StreamEvent in s
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
                            remote:NIOAsyncChannelInboundStream<HTTP2Frame.FramePayload>,
                            writer:NIOAsyncChannelOutboundWriter<HTTP2Frame.FramePayload>
                        )   in

                        let message:HTTP.ServerMessage<Authority, HPACKHeaders>
                        do
                        {
                            message = .init(
                                response: try await self.respond(to: remote,
                                    address: address,
                                    service: service,
                                    as: Authority.self),
                                using: stream.frames.channel.allocator)
                        }
                        catch let error
                        {
                            Log[.error] = "(application: \(address)) \(error)"

                            message = .init(
                                redacting: error,
                                using: stream.frames.channel.allocator)
                        }

                        try await writer.send(message)
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
                    //  the second `GOAWAY` frame. Notably, Firefox will not close the
                    //  connection for us. And per the semantics of `GOAWAY`, we have not
                    //  committed to handling any subsequent streams.
                    return
                }
            }
        }
        catch let error
        {
            Log[.error] = "(HTTP/2: \(address)) \(error)"
        }
    }

    private
    func respond<Authority>(to h2:NIOAsyncChannelInboundStream<HTTP2Frame.FramePayload>,
        address:IP.V6,
        service:IP.Service?,
        as _:Authority.Type) async throws -> HTTP.ServerResponse
        where Authority:ServerAuthority
    {
        /// Do the ``AsyncStream`` ritual dance.
        var c:AsyncThrowingStream<HTTP2Frame.FramePayload?, any Error>.Continuation? = nil
        let s:AsyncThrowingStream<HTTP2Frame.FramePayload?, any Error> = .init { c = $0 }
        guard
        let c:AsyncThrowingStream<HTTP2Frame.FramePayload?, any Error>.Continuation
        else
        {
            fatalError("unreachable")
        }
        /// Launch the task that simply forwards the output of the
        /// ``NIOAsyncChannelInboundStream`` to the combined stream. This seems comically
        /// inefficient, but it is needed in order to add timeout events to an HTTP/2 stream.
        async
        let _:Void =
        {
            do
            {
                for try await frame:HTTP2Frame.FramePayload in $1
                {
                    $0.yield(frame)
                }

                $0.finish()
            }
            catch let error
            {
                $0.finish(throwing: error)
            }
        } (c, h2)
        /// Launch the task that emits a timeout event after 5 seconds. This doesn’t terminate
        /// the stream because we want to be able to ignore the timeout events after the peer
        /// completes authentication, if applicable. This allows us to accept long-running
        /// uploads from trusted peers.
        async
        let _:Void =
        {
            try? await Task.sleep(for: .seconds(5))
            $0.yield(nil)
        } (c)

        var inbound:AsyncThrowingStream<HTTP2Frame.FramePayload?, any Error>.AsyncIterator
        var headers:HPACKHeaders? = nil

        /// Wait for the `HEADERS` frame, which initiates the application-level request. This
        /// frame contains cookies, so after we get it, we will know if we can ignore timeouts.
        waiting:
        do
        {
            inbound = s.makeAsyncIterator()

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
