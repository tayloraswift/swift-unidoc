import HTML
import HTTP
import NIOCore
import NIOHTTP1
import NIOPosix
import NIOSSL

extension HTTP.ServerOrigin
{
    func link(_ uri:String, rel:HTML.Attribute.Rel) -> String
    {
        "<\(self)\(uri)>; rel=\"\(rel)\""
    }
}
extension HTTP.ServerOrigin
{
    public
    func redirect(
        from host:String,
        port:Int,
        onConnectionError handle:@Sendable @escaping (any Error) -> ()) async throws
    {
        let bootstrap:ServerBootstrap = .init(group: MultiThreadedEventLoopGroup.singleton)
            .serverChannelOption(ChannelOptions.backlog, value: 256)
            .serverChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .childChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 1)

        let listener:NIOAsyncChannel<any Channel, Never> = try await bootstrap.bind(
            host: host,
            port: port)
        {
            (connection:any Channel) in

            connection.eventLoop.makeCompletedFuture
            {
                try connection.pipeline.syncOperations.configureHTTPServerPipeline(
                    withErrorHandling: true)

                try connection.pipeline.syncOperations.addHandler(
                    HTTP.ServerRedirectorHandler.init(target: self))

                return connection
            }
        }

        try await listener.executeThenClose
        {
            try await $0.iterate(concurrently: 20)
            {
                (connection:any Channel) in

                /// Once we receive a connection, the peer has 4 seconds to send a request
                /// before we enforce a timeout.
                async
                let _:Void =
                {
                    try await Task.sleep(for: .seconds(4))
                    try await connection.close()
                }()
                do
                {
                    try await connection.closeFuture.get()
                }
                catch let error
                {
                    handle(error)
                }
            }
        }
    }
}
