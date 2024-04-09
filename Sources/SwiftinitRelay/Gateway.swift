import NIOCore
import NIOPosix

#if canImport(Glibc)
import Glibc
#elseif canImport(Darwin)
import Darwin
#endif

func print(_ items:Any..., separator:String = " ", terminator:String = "\n")
{
    for item:Any in items
    {
        Swift.print(item, separator: "", terminator: separator)
    }

    Swift.print(terminator, terminator: "")

    if  terminator.contains(where: \.isNewline)
    {
        fflush(stdout)
    }
}

struct Gateway:Sendable
{
    /// A hostname, which may not be publicly resolvable.
    let host:String
    /// A port to direct traffic for the ``host`` to.
    let port:Int
    /// A port to bind to, allowing external traffic to reach the ``host``.
    let portBinding:Int

    init(host:String, port:Int, portBinding:Int)
    {
        self.host = host
        self.port = port
        self.portBinding = portBinding
    }
}
extension Gateway:CustomStringConvertible
{
    var description:String
    {
        "\(self.host):\(self.port)@\(self.portBinding)"
    }
}
extension Gateway:LosslessStringConvertible
{
    init?(_ string:String)
    {
        guard
        let at:String.Index = string.lastIndex(of: "@"),
        let portBinding:Int = .init(string[string.index(after: at)...]),
        let colon:String.Index = string[..<at].lastIndex(of: ":"),
        let port:Int = .init(string[string.index(after: colon) ..< at])
        else
        {
            return nil
        }

        self.init(host: String.init(string[..<colon]), port: port, portBinding: portBinding)
    }
}
extension Gateway
{
    func listen(on threads:MultiThreadedEventLoopGroup) async throws
    {
        let bootstrap:ServerBootstrap = .init(group: threads)
            .serverChannelOption(ChannelOptions.socket(.init(SOL_SOCKET), SO_REUSEADDR),
                value: 1)
            .childChannelOption(ChannelOptions.socket(.init(SOL_SOCKET), SO_REUSEADDR),
                value: 1)
            .childChannelInitializer
        {
            (incoming:any Channel) in

            let incomingHandler:GatewayHandler
            let outgoingHandler:NIOLoopBound<GatewayHandler>

            (incomingHandler, outgoingHandler) = GatewayHandler.bridge(on: incoming.eventLoop)

            let bootstrap:ClientBootstrap = .init(group: incoming.eventLoop)
                .connectTimeout(.seconds(3))
                .channelInitializer
            {
                $0.pipeline.addHandler(outgoingHandler.value)
            }

            let future:EventLoopFuture = incoming.pipeline.addHandler(incomingHandler)
                .and(bootstrap.connect(host: self.host, port: self.port))
                .map
            {
                _ in print("Forwarding connection to \(host)")
            }

            //  Break reference cycle.
            future.whenFailure
            {
                _ in outgoingHandler.value.unlink()
            }

            return future
        }

        let channel:any Channel = try await bootstrap.bind(host: "::",
            port: self.portBinding).get()

        print("Activated gateway \(self)")

        try await channel.closeFuture.get()
    }
}

