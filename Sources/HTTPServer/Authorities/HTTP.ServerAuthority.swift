import HTML
import HTTP
import NIOCore
import NIOHTTP1
import NIOPosix
import NIOSSL
import TraceableErrors

extension HTTP
{
    public
    protocol ServerAuthority<SecurityContext>:Sendable
    {
        associatedtype SecurityContext

        static
        var scheme:Scheme { get }
        static
        var domain:String { get }

        var context:SecurityContext { get }

        init(context:SecurityContext)

        static
        func redact(error:any Error) -> String
    }
}
extension HTTP.ServerAuthority
{
    /// Dumps detailed information about the caught error. This information will be shown to
    /// *anyone* accessing the server. In production, we strongly recommend overriding this
    /// default implementation to avoid inadvertently exposing sensitive data via type
    /// reflection.
    public static
    func redact(error:any Error) -> String
    {
        var notes:[String] = []
        var next:any Error = error
        while true
        {
            switch next
            {
            case let current as any TraceableError:
                notes.append(contentsOf: current.notes)
                next = current.underlying

            case let last:
                var description:String = last.headline(plaintext: true)
                for note:String in notes.reversed()
                {
                    description += "\nNote: \(note)"
                }
                return description
            }
        }
    }
}
extension HTTP.ServerAuthority
{
    /// Formats a URL from the given URI. The URI should begin with a slash.
    static
    func url(_ uri:String) -> String
    {
        switch self.scheme
        {
        case .http(port: 80):           "http://\(self.domain)\(uri)"
        case .http(port: let port):     "http://\(self.domain):\(port)\(uri)"
        case .https(port: 443):         "https://\(self.domain)\(uri)"
        case .https(port: let port):    "https://\(self.domain):\(port)\(uri)"
        }
    }
    static
    func link(_ uri:String, rel:HTML.Attribute.Rel) -> String
    {
        "<\(Self.url(uri))>; rel=\"\(rel)\""
    }
}
extension HTTP.ServerAuthority
{
    public static
    func redirect(
        from binding:(address:String, port:Int),
        on threads:MultiThreadedEventLoopGroup) async throws
    {
        let bootstrap:ServerBootstrap = .init(group: threads)
            .serverChannelOption(ChannelOptions.backlog, value: 256)
            .serverChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .childChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 1)

        let listener:NIOAsyncChannel<any Channel, Never> = try await bootstrap.bind(
            host: binding.address,
            port: binding.port)
        {
            (connection:any Channel) in

            connection.eventLoop.makeCompletedFuture
            {
                try connection.pipeline.syncOperations.configureHTTPServerPipeline(
                    withErrorHandling: true)

                try connection.pipeline.syncOperations.addHandler(
                    HTTP.ServerRedirectorHandler<Self>.init())

                return connection
            }
        }

        Log[.debug] = "bound to \(binding.address):\(binding.port)"

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
                    Log[.error] = "\(error)"
                }
            }
        }
    }
}
