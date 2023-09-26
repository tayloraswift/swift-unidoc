import HTTPClient
import ModuleGraphs
import NIOCore
import NIOPosix
import NIOSSL
import UnidocAutomation

@main
enum Main
{
    static
    func main() async throws
    {
        let options:Options = try .parse()

        let threads:MultiThreadedEventLoopGroup = .init(numberOfThreads: 2)

        var configuration:TLSConfiguration = .makeClientConfiguration()
            configuration.applicationProtocols = ["h2"]
        let niossl:NIOSSLContext = try .init(configuration: configuration)

        let http2:HTTP2Client = .init(
            threads: threads,
            niossl: niossl,
            remote: options.remote)

        let swiftinit:SwiftinitClient = .init(http2: http2, cookie: options.cookie)

        let status:PackageBuildStatus = try await swiftinit.get(
            from: "/api/build/\(options.package)")

        let builder:Massbuilder = try await .init()

        try await builder.build(options.package,
            repository: status.repo,
            at: status.release.tag)
    }
}

extension Main
{
    struct Options
    {
        var package:PackageIdentifier
        var cookie:String
        var remote:String

        private
        init(package:PackageIdentifier)
        {
            self.package = package
            self.cookie = ""
            self.remote = "swiftinit.org"
        }
    }
}
extension Main.Options
{
    static
    func parse() throws -> Self
    {
        var arguments:ArraySlice<String> = CommandLine.arguments[1...]

        guard
        let package:String = arguments.popFirst()
        else
        {
            fatalError("Usage: \(CommandLine.arguments[0]) <package>")
        }

        var options:Self = .init(package: .init(package))

        while let option:String = arguments.popFirst()
        {
            switch option
            {
            case "--cookie", "-i":
                guard
                let cookie:String = arguments.popFirst()
                else
                {
                    fatalError("Expected cookie after '\(option)'")
                }

                options.cookie = cookie

            case "--remote", "-h":
                guard
                let remote:String = arguments.popFirst()
                else
                {
                    fatalError("Expected remote hostname after '\(option)'")
                }

                options.remote = remote

            case let option:
                fatalError("Unknown option '\(option)'")
            }
        }

        return options
    }
}

import JSON

@frozen public
struct SwiftinitClient
{
    @usableFromInline internal
    let http2:HTTP2Client
    @usableFromInline internal
    let cookie:String

    @inlinable public
    init(http2:HTTP2Client, cookie:String)
    {
        self.http2 = http2
        self.cookie = cookie
    }
}
extension SwiftinitClient
{
    @inlinable public
    func connect<T>(with body:(Connection) async throws -> T) async throws -> T
    {
        try await self.http2.connect
        {
            try await body(Connection.init(http2: $0,
                cookie: self.cookie,
                remote: self.http2.remote))
        }
    }
}
extension SwiftinitClient
{
    @inlinable public
    func get<Response>(_:Response.Type = Response.self,
        from endpoint:String) async throws -> Response where Response:JSONDecodable
    {
        try await self.connect { try await $0.get(from: endpoint) }
    }
}

import JSON
import NIOHPACK

extension SwiftinitClient
{
    @frozen public
    struct Connection
    {
        @usableFromInline internal
        let http2:HTTP2Client.Connection
        @usableFromInline internal
        let cookie:String
        @usableFromInline internal
        let remote:String

        @inlinable internal
        init(http2:HTTP2Client.Connection, cookie:String, remote:String)
        {
            self.http2 = http2
            self.cookie = cookie
            self.remote = remote
        }
    }
}
extension SwiftinitClient.Connection
{
    @inlinable public
    func get<Response>(_:Response.Type = Response.self,
        from endpoint:String) async throws -> Response where Response:JSONDecodable
    {
        var endpoint:String = endpoint
        var status:UInt? = nil

        following:
        for _:Int in 0 ... 1
        {
            let request:HPACKHeaders =
            [
                ":method": "GET",
                ":scheme": "https",
                ":authority": self.remote,
                ":path": endpoint,

                "user-agent": "UnidocBuild",
                "accept": "application/json",
                "cookie": "__Host-session=\(self.cookie)",
            ]

            let response:HTTP2Client.Facet = try await self.http2.fetch(request)

            switch response.status
            {
            case 200?:
                var json:JSON = .init(utf8: [])
                for buffer:ByteBuffer in response.buffers
                {
                    json.utf8 += buffer.readableBytesView
                }

                return try json.decode()
            case 301?:
                if  let location:String = response.headers?["location"].first
                {
                    endpoint = String.init(location.trimmingPrefix("https://\(self.remote)"))
                    continue following
                }
            case _:
                break
            }

            status = response.status
            break following
        }

        throw SwiftinitClient.StatusError.init(code: status)
    }
}

extension SwiftinitClient
{
    @frozen public
    struct StatusError:Equatable, Sendable, Error
    {
        /// The response status code, if it could be parsed, nil otherwise.
        public
        let code:UInt?

        @inlinable public
        init(code:UInt?)
        {
            self.code = code
        }
    }
}
extension SwiftinitClient.StatusError:CustomStringConvertible
{
    public
    var description:String
    {
        self.code?.description ?? "unknown"
    }
}
