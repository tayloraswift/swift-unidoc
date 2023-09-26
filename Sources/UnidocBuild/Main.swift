import BSON
import HTTPClient
import ModuleGraphs
import NIOCore
import NIOPosix
import NIOSSL
import SymbolGraphBuilder
import SymbolGraphs
import UnidocAutomation
import UnidocLinker

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

        try await swiftinit.connect
        {
            let package:PackageBuildStatus = try await $0.get(
                from: "/api/build/\(options.package)")

            let toolchain:Toolchain = try await .detect()
            let workspace:Workspace = try await .create(at: ".swiftinit")

            let edition:PackageBuildStatus.Edition

            if  package.release.graphs == 0
            {
                edition = package.release
            }
            else if
                let prerelease:PackageBuildStatus.Edition = package.prerelease,
                    prerelease.graphs == 0
            {
                edition = prerelease
            }
            else
            {
                print("No new documentation to build")
                return
            }

            let build:PackageBuild = try await .remote(
                package: options.package,
                from: package.repo,
                at: edition.tag,
                in: workspace,
                clean: true)

            let snapshot:Snapshot = .init(
                package: package.coordinate,
                version: edition.coordinate,
                archive: try await toolchain.generateDocs(for: build, pretty: options.pretty))

            let bson:BSON.Document = .init(encoding: consume snapshot)

            try await $0.put(bson: bson, to: "/api/symbolgraph")

            print("Successfully uploaded symbol graph (tag: \(edition.tag))")
        }
    }
}

extension Main
{
    struct Options
    {
        var package:PackageIdentifier
        var cookie:String
        var remote:String
        var pretty:Bool

        private
        init(package:PackageIdentifier)
        {
            self.package = package
            self.cookie = ""
            self.remote = "swiftinit.org"
            self.pretty = false
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

            case "--pretty", "-p":
                options.pretty = true

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
import Media
import NIOHPACK
import URI

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
    @inlinable internal
    func headers(_ method:String, _ endpoint:String) -> HPACKHeaders
    {
        [
            ":method": method,
            ":scheme": "https",
            ":authority": self.remote,
            ":path": endpoint,

            "user-agent": "UnidocBuild",
            "accept": "application/json",
            "cookie": "__Host-session=\(self.cookie)",
        ]
    }
}
extension SwiftinitClient.Connection
{
    @discardableResult
    @inlinable public
    func post(urlencoded:consuming String, to endpoint:String) async throws -> [ByteBuffer]
    {
        try await self.fetch(endpoint, method: "POST",
            body: self.http2.buffer(string: urlencoded),
            type: .application(.x_www_form_urlencoded))
    }

    @discardableResult
    @inlinable public
    func put(bson:consuming BSON.Document, to endpoint:String) async throws -> [ByteBuffer]
    {
        try await self.fetch(endpoint, method: "PUT",
            body: self.http2.buffer(bytes: (consume bson).bytes),
            type: .application(.bson))
    }

    @inlinable public
    func get<Response>(_:Response.Type = Response.self,
        from endpoint:String) async throws -> Response where Response:JSONDecodable
    {
        var json:JSON = .init(utf8: [])

        for buffer:ByteBuffer in try await self.fetch(endpoint, method: "GET")
        {
            json.utf8 += buffer.readableBytesView
        }

        return try json.decode()
    }
}
extension SwiftinitClient.Connection
{
    @inlinable internal
    func fetch(_ endpoint:String,
        method:String,
        body:ByteBuffer? = nil,
        type:MediaType? = nil) async throws -> [ByteBuffer]
    {
        var endpoint:String = endpoint
        var status:UInt? = nil

        following:
        for _:Int in 0 ... 1
        {
            var headers:HPACKHeaders = self.headers(method, endpoint)
            if  let type:MediaType
            {
                headers.add(name: "content-type", value: "\(type)")
            }

            let response:HTTP2Client.Facet = try await self.http2.fetch(.init(
                headers: headers,
                body: body))

            switch response.status
            {
            case 200?:
                return response.buffers

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
