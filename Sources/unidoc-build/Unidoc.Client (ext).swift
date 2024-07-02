import HTTP
import NIOPosix
import UnidocClient

extension Unidoc.Client<HTTP.Client1>
{
    init(from options:Main.Local) throws
    {
        let threads:MultiThreadedEventLoopGroup = .init(numberOfThreads: 2)

        print("Connecting to \(options.host):\(options.port)...")

        self.init(
            swiftRuntime: options.swiftRuntime,
            swiftPath: options.swiftPath,
            swiftSDK: options.swiftSDK,
            pretty: options.pretty,
            authorization: nil,
            http: .init(threads: threads, niossl: nil, remote: options.host),
            port: options.port)
    }
}
