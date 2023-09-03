import NIOCore
import NIOPosix
import NIOHPACK
import NIOHTTP2
import NIOSSL

@frozen public
struct ClientInterface
{
    @usableFromInline internal
    let bootstrap:ClientBootstrap

    /// The hostname of the remote service.
    public
    let remote:String

    private
    init(bootstrap:ClientBootstrap, remote:String)
    {
        self.bootstrap = bootstrap
        self.remote = remote
    }
}
extension ClientInterface:Identifiable
{
    /// Returns the ``remote`` hostname.
    @inlinable public
    var id:String { self.remote }
}
extension ClientInterface
{
    public
    init(threads:MultiThreadedEventLoopGroup, niossl:NIOSSLContext, remote:String)
    {
        let bootstrap:ClientBootstrap = .init(group: threads)
            .connectTimeout(.seconds(3))
            .channelInitializer
        {
            (channel:any Channel) in

            do
            {
                let tls:NIOSSLClientHandler = try .init(context: niossl,
                    serverHostname: remote)

                return channel.pipeline.addHandler(tls)
                    .flatMap
                {
                    channel.configureHTTP2Pipeline(mode: .client,
                        connectionConfiguration: .init(),
                        streamConfiguration: .init())
                    {
                        //  With no owner, the stream is unsolicited and will drop any
                        //  responses it receives.
                        $0.pipeline.addHandler(ClientStreamHandler.init(owner: nil))
                    }
                        .flatMap
                    {
                        (multiplexer:NIOHTTP2Handler.StreamMultiplexer) in

                        channel.pipeline.addHandler(ClientInterfaceHandler.init(
                            multiplexer: multiplexer))
                    }
                }
            }
            catch let error
            {
                return channel.eventLoop.makeFailedFuture(error)
            }
        }

        self.init(bootstrap: bootstrap, remote: remote)
    }
}
extension ClientInterface
{
    public
    func fetch(_ request:__owned HPACKHeaders) async throws -> Facet
    {
        try await self.fetch(reducing: [request], into: .init()) { $0 = $1 }
    }

    public
    func fetch(_ batch:__owned [HPACKHeaders]) async throws -> [Facet]
    {
        try await self.fetch(reducing: batch, into: []) { $0.append($1) }
    }

    @inlinable public
    func fetch<Response>(reducing batch:__owned [HPACKHeaders],
        into initial:__owned Response,
        with combine:(inout Response, Facet) throws -> ()) async throws -> Response
    {
        if  batch.isEmpty
        {
            return initial
        }

        let channel:any Channel = try await self.bootstrap.connect(
            host: self.remote,
            port: 443).get()

        defer
        {
            channel.close(promise: nil)
        }

        var response:Response = initial

        var source:AsyncThrowingStream<Facet, any Error>.Continuation?
        let stream:AsyncThrowingStream<Facet, any Error> = .init
        {
            source = $0
        }
        if  let source
        {
            channel.closeFuture.whenComplete
            {
                _ in
                source.finish()
            }

            async
            let _:Void =
            {
                try await Task.sleep(for: .seconds(3))
                source.finish(throwing: RequestTimeoutError.init())
            }()

            let awaiting:Int = batch.count
            var facets:AsyncThrowingStream<Facet, any Error>.Iterator =
                stream.makeAsyncIterator()

            channel.write((source, batch), promise: nil)
            channel.flush()

            for _:Int in 0 ..< awaiting
            {
                if  let facet:Facet = try await facets.next()
                {
                    try combine(&response, facet)
                }
                else
                {
                    throw UnexpectedStreamTerminationError.init()
                }
            }
        }

        return response
    }
}
