import BSON
import HTTPClient
import NIOCore
import NIOPosix
import NIOSSL
import SymbolGraphBuilder
import SymbolGraphs
import Symbols
import System
import UnidocAPI
import UnidocRecords

extension Unidoc
{
    @frozen public
    struct Client
    {
        @usableFromInline internal
        let http2:HTTP2Client
        @usableFromInline internal
        let port:Int
        @usableFromInline internal
        let cookie:String

        @inlinable
        init(http2:HTTP2Client, cookie:String, port:Int)
        {
            self.http2 = http2
            self.cookie = cookie
            self.port = port
        }
    }
}
extension Unidoc.Client
{
    init(host:String, port:Int, cookie:String) throws
    {
        let threads:MultiThreadedEventLoopGroup = .init(numberOfThreads: 2)

        var configuration:TLSConfiguration = .makeClientConfiguration()
            configuration.applicationProtocols = ["h2"]

        //  If we are not using the default port, we are probably running locally.
        if  port != 443
        {
            configuration.certificateVerification = .none
        }

        let niossl:NIOSSLContext = try .init(configuration: configuration)

        print("Connecting to \(host):\(port)...")

        let http2:HTTP2Client = .init(
            threads: threads,
            niossl: niossl,
            remote: host)

        self.init(http2: http2, cookie: cookie, port: port)
    }
}
extension Unidoc.Client
{
    @inlinable public
    func connect<T>(with body:(Connection) async throws -> T) async throws -> T
    {
        try await self.http2.connect(port: self.port)
        {
            try await body(Connection.init(http2: $0, cookie: self.cookie))
        }
    }
}
extension Unidoc.Client
{
    func buildAndUpload(local symbol:Symbol.Package,
        search:FilePath?,
        toolchain:SSGC.Toolchain) async throws
    {
        fatalError("unimplemented")
        // let workspace:SSGC.Workspace = try .create(at: ".unidoc")

        // let object:SymbolGraphObject<Void>
        // if  symbol == .swift
        // {
        //     let build:SSGC.SpecialBuild = try .swift(in: workspace,
        //         clean: true)

        //     object = try .init(building: build, with: toolchain)
        // }
        // else if
        //     let search:FilePath
        // {
        //     let build:SSGC.PackageBuild = try .local(package: symbol,
        //         from: search,
        //         in: workspace,
        //         clean: true)

        //     object = try .init(building: build, with: toolchain)
        // }
        // else
        // {
        //     fatalError("No package search path specified.")
        // }

        // try await self.connect
        // {
        //     @Sendable (connection:Unidoc.Client.Connection) in

        //     try await connection.upload(object)
        // }
    }

    func buildAndUpload(remote symbol:Symbol.Package,
        force:Unidoc.VersionSeries?,
        toolchain:SSGC.Toolchain) async throws
    {
        //  Building the package might take a long time, and the server might close the
        //  connection before the build is finished. So we do not try to keep this
        //  connection open.
        let labels:Unidoc.BuildLabels? = try await self.connect
        {
            @Sendable (connection:Unidoc.Client.Connection) in

            do
            {
                return try await connection.latest(force, of: symbol)
            }
            catch let error as HTTP.StatusError
            {
                guard
                case 404? = error.code
                else
                {
                    throw error
                }

                return nil
            }
        }

        guard
        let labels:Unidoc.BuildLabels
        else
        {
            print("Not a buildable package.")
            return
        }

        let result:Unidoc.Build = try await .with(toolchain: toolchain,
            labels: labels,
            action: force != nil ? .uplinkRefresh : .uplinkInitial)

        try await self.connect
        {
            @Sendable (connection:Unidoc.Client.Connection) in

            switch result
            {
            case .success(let labeled):
                try await connection.upload(labeled)

            case .failure(let report):
                try await connection.upload(report)
            }
        }
    }

    func buildAndUploadQueued(toolchain:SSGC.Toolchain) async throws
    {
        let labels:Unidoc.BuildLabels = try await self.connect
        {
            @Sendable (connection:Unidoc.Client.Connection) in

            try await connection.get(from: "/ssgc/poll", timeout: .seconds(60 * 60))
        }

        print("""
            Building package '\(labels.package)' at '\(labels.tag ?? "?")' \
            (\(labels.coordinate))
            """)

        let result:Unidoc.Build = try await .with(toolchain: toolchain,
            labels: labels,
            action: .uplinkRefresh)

        try await self.connect
        {
            @Sendable (connection:Unidoc.Client.Connection) in

            switch result
            {
            case .success(let labeled):
                try await connection.upload(labeled)

            case .failure(let report):
                try await connection.upload(report)
            }
        }
    }
}
