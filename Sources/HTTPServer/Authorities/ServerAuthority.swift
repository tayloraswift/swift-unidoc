import HTML
import NIOCore
import NIOHTTP1
import NIOPosix
import NIOSSL
import TraceableErrors

public
protocol ServerAuthority:Sendable
{
    static
    var scheme:ServerScheme { get }
    static
    var domain:String { get }

    var tls:NIOSSLContext { get }

    static
    func redact(error:any Error) -> String
}
extension ServerAuthority
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
extension ServerAuthority
{
    /// Formats a URL from the given URI. The URI should begin with a slash.
    static
    func url(_ uri:String) -> String
    {
        switch self.scheme
        {
        case .https(port: 443):         return "https://\(self.domain)\(uri)"
        case .https(port: let port):    return "https://\(self.domain):\(port)\(uri)"
        }
    }
    static
    func link(_ uri:String, rel:HTML.Attribute.Rel) -> String
    {
        "<\(Self.url(uri))>; rel=\"\(rel)\""
    }
}
extension ServerAuthority
{
    public static
    func redirect(from binding:(address:String, port:Int),
        on threads:MultiThreadedEventLoopGroup) async throws
    {
        let bootstrap:ServerBootstrap = .init(group: threads)
            .serverChannelOption(ChannelOptions.backlog, value: 256)
            .serverChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .childChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 1)
            .childChannelOption(ChannelOptions.allowRemoteHalfClosure, value: true)
            .childChannelInitializer
        {
            (channel:any Channel) -> EventLoopFuture<Void> in

            let endpoint:ServerRedirectorHandler<Self> = .init()

            return channel.pipeline.configureHTTPServerPipeline(withErrorHandling: true)
                .flatMap
            {
                channel.pipeline.addHandler(endpoint)
            }
        }

        let channel:any Channel = try await bootstrap.bind(
            host: binding.address,
            port: binding.port).get()

        print("bound to:", binding.address, binding.port)

        try await channel.closeFuture.get()
    }
}
