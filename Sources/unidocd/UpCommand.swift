#if canImport(Darwin)
@preconcurrency import Darwin
#elseif canImport(Glibc)
@preconcurrency import Glibc
#endif

import ArgumentParser
import HTTPClient
import NIOCore
import NIOSSL
import Symbols
import SystemIO
import SymbolGraphBuilder
import UnidocClient

struct UpCommand {
    @Option(
        name: [.customLong("swiftinit"), .customShort("S")],
        help: """
        The API key for the Unidoc server running on swiftinit.org, \
        also sets the host and port to the production values
        """
    ) var authorizationSwiftinit: String?

    @Option(
        name: [.customLong("authorization"), .customShort("i")],
        help: "The API key for the Unidoc server"
    ) var authorization: String?

    @Option(
        name: [.customLong("host"), .customShort("h")],
        help: "The name of a host running a compatible instance of unidoc"
    ) var host: String = "localhost"

    @Option(
        name: [.customLong("port"), .customShort("p")],
        help: "The number of a port bound to a compatible instance of unidoc"
    ) var port: Int = 8443

    @Option(
        name: [.customLong("swift-toolchain"), .customShort("u")],
        help: "The path to a Swift toolchain directory, usually ending in 'usr'",
        completion: .directory
    ) var toolchain: FilePath.Directory = "/home/ubuntu/6.2.3/aarch64/usr"

    @Option(
        name: [.customLong("swift-sdk"), .customShort("k")],
        help: "The Swift SDK to use"
    ) var sdk: SSGC.AppleSDK?

    @Flag(
        name: [.customLong("pretty"), .customShort("o")],
        help: "Tell lib/SymbolGraphGen to pretty-print the JSON output, if possible"
    ) var pretty: Bool = false

    @Flag(
        name: [.customLong("init-stdlib")],
        help: "Generate and upload the standard library documentation"
    ) var initStandardLibrary: Bool = false
}
extension UpCommand {
    private mutating func normalize() {
        if  let authorization: String = self.authorizationSwiftinit,
            case nil = self.authorization {
            self.authorization = authorization
            self.host = "swiftinit.org"
            self.port = 443
        }

        #if os(macOS)

        //  Guess the SDK if not specified.
        self.sdk = self.sdk ?? .macOS

        #endif
    }

    private var client: Unidoc.Client<HTTP.Client2> {
        get throws {
            var configuration: TLSConfiguration = .makeClientConfiguration()
            configuration.applicationProtocols = ["h2"]

            //  If we are not using the default port, we are probably running locally.
            if  self.port != 443 {
                configuration.certificateVerification = .none
            }

            return .init(
                authorization: self.authorization,
                pretty: self.pretty,
                http: .init(
                    threads: .singleton,
                    niossl: try .init(configuration: configuration),
                    remote: self.host
                ),
                port: self.port
            )
        }
    }

    private var triple: Symbol.Triple {
        get throws {
            let tools: SSGC.Toolchain.Paths = .init(swiftPM: nil, usr: self.toolchain)
            let splash: SSGC.Toolchain.Splash = try .init(running: tools.swiftCommand)
            return splash.triple
        }
    }
}
extension UpCommand: AsyncParsableCommand {
    static var configuration: CommandConfiguration {
        .init(commandName: "up")
    }

    mutating func run() async throws {
        self.normalize()

        NIOSingletons.groupLoopCountSuggestion = 2
        setlinebuf(stdout)

        let unidoc: Unidoc.Client<HTTP.Client2> = try self.client
        let triple: Symbol.Triple = try self.triple
        let cache: FilePath = "swiftpm"

        print("Connecting to \(self.host):\(self.port)...")

        if  self.initStandardLibrary {
            let toolchain: Unidoc.Toolchain = .init(usr: self.toolchain, sdk: self.sdk)
            try await unidoc.buildAndUpload(
                local: nil,
                name: "swift",
                type: .package,
                with: toolchain
            )
        }

        while true {
            //  Don’t run too hot if the network is down.
            async let cooldown: Void = try await Task.sleep(for: .seconds(5))

            do {
                let labels: Unidoc.BuildLabels? = try await unidoc.connect {
                    try await $0.subscribe(to: triple)
                }

                if  let labels: Unidoc.BuildLabels {
                    print("""
                        Building package '\(labels.package)' at '\(labels.ref)' \
                        (\(labels.coordinate))
                        """)

                    let toolchain: Unidoc.Toolchain = .init(usr: self.toolchain, sdk: self.sdk)
                    /// As this runs continuously, we should remove the build artifacts
                    /// afterwards, to avoid filling up the disk. We must also remove the cloned
                    /// repository, as it may experience name conflicts on long timescales.
                    try await unidoc.buildAndUpload(
                        labels: labels,
                        remove: true,
                        with: toolchain,
                        cache: cache
                    )
                } else {
                    print("Heartbeat received; no packages to build.")
                }
            } catch let error {
                print("Error: \(error)")
            }

            try await cooldown
        }
    }
}
