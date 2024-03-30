import HTTPClient
import NIOCore
import NIOPosix
import NIOSSL
import Symbols
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
        let toolchain:SSGC.Toolchain = try await .detect(
            swiftPath: options.swift ?? "swift",
            swiftSDK: options.swiftSDK)

        let threads:MultiThreadedEventLoopGroup = .init(numberOfThreads: 2)

        var configuration:TLSConfiguration = .makeClientConfiguration()
            configuration.applicationProtocols = ["h2"]

        //  If we are not using the default port, we are probably running locally.
        if  options.port != 443
        {
            configuration.certificateVerification = .none
        }

        let niossl:NIOSSLContext = try .init(configuration: configuration)

        print("Connecting to \(options.host):\(options.port)...")

        let http2:HTTP2Client = .init(
            threads: threads,
            niossl: niossl,
            remote: options.host)

        let unidoc:Unidoc.Client = .init(http2: http2,
            cookie: options.cookie,
            port: options.port)


        switch options.tool
        {
        case .builder:
            try await unidoc.builder(toolchain: toolchain)

        case .upgrade:
            try await unidoc.upgrade(toolchain: toolchain, pretty: options.pretty)

        case .latest:
            guard
            let package:Symbol.Package = options.package
            else
            {
                fatalError("No package specified")
            }

            if  package != .swift,
                options.input == nil
            {
                try await unidoc.buildAndUpload(remote: package,
                    pretty: options.pretty,
                    force: options.force,
                    toolchain: toolchain)
            }
            else
            {
                try await unidoc.buildAndUpload(local: package,
                    search: options.input.map(FilePath.init(_:)),
                    pretty: options.pretty,
                    toolchain: toolchain)
            }
        }
    }
}
