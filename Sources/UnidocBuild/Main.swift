import HTTPClient
import NIOCore
import NIOPosix
import NIOSSL
import System
import UnidocAPI

@main
enum Main
{
    static
    func main() async
    {
        await SystemProcess.do(Self._main)
    }

    private static
    func _main() async throws
    {
        let options:Options = try .parse()

        let threads:MultiThreadedEventLoopGroup = .init(numberOfThreads: 2)

        var configuration:TLSConfiguration = .makeClientConfiguration()
            configuration.applicationProtocols = ["h2"]

        //  If we are not using the default port, we are probably running locally.
        if  options.port != 443
        {
            configuration.certificateVerification = .none
        }

        let niossl:NIOSSLContext = try .init(configuration: configuration)

        print("Connecting to \(options.remote):\(options.port)...")

        let http2:HTTP2Client = .init(
            threads: threads,
            niossl: niossl,
            remote: options.remote)

        let swiftinit:SwiftinitClient = .init(http2: http2,
            cookie: options.cookie,
            port: options.port)

        switch options.tool
        {
        case .uplinkMultiple:
            guard
            let input:String = options.input
            else
            {
                fatalError("Missing input file")
            }

            try await swiftinit.uplink(editions: FilePath.init(input))

        case .uplink:
            try await swiftinit.uplink(package: options.package)

        case .build:
            if  options.package != .swift,
                options.input == nil
            {
                try await swiftinit.build(remote: options.package,
                    pretty: options.pretty,
                    force: options.force)
            }
            else
            {
                try await swiftinit.build(local: options.package,
                    search: options.input.map(FilePath.init(_:)),
                    pretty: options.pretty)
            }
        }
    }
}
