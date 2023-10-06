import BSON
import HTTPClient
import ModuleGraphs
import NIOCore
import NIOPosix
import NIOSSL
import SemanticVersions
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
        if  options.remote == "localhost"
        {
            configuration.certificateVerification = .none
        }

        let niossl:NIOSSLContext = try .init(configuration: configuration)

        let http2:HTTP2Client = .init(
            threads: threads,
            niossl: niossl,
            remote: options.remote)

        let swiftinit:SwiftinitClient = .init(http2: http2, cookie: options.cookie)

        try await swiftinit.connect(port: options.port)
        {
            let package:PackageBuildStatus = try await $0.get(
                from: "/api/build/\(options.package)")

            let toolchain:Toolchain = try await .detect()
            let workspace:Workspace = try await .create(at: ".swiftinit")

            let edition:PackageBuildStatus.Edition

            if  options.build
            {
                /// Only build prereleases if the latest release has already been built, and
                /// the prerelease has a higher patch version.
                if  package.release.graphs == 0 || options.force
                {
                    edition = package.release
                }
                else if
                    let prerelease:PackageBuildStatus.Edition = package.prerelease,
                        prerelease.graphs == 0,
                    let version:SemanticVersion = .init(refname: prerelease.tag),
                    let release:SemanticVersion = .init(refname: package.release.tag),
                        release.patch < version.patch
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

                //  Remove the `Package.resolved` file to force a new resolution.
                try await build.removePackageResolved()

                let snapshot:Snapshot = .init(
                    package: package.coordinate,
                    version: edition.coordinate,
                    archive: try await toolchain.generateDocs(for: build, pretty: options.pretty))

                let bson:BSON.Document = .init(encoding: consume snapshot)

                print("Uploading symbol graph...")

                try await $0.put(bson: bson, to: "/api/symbolgraph")

                print("Successfully uploaded symbol graph (tag: \(edition.tag))")
            }
            else
            {
                edition = package.release
            }

            try await $0.post(
                urlencoded: "package=\(package.coordinate)&version=\(edition.coordinate)",
                to: "/api/uplink")
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
        var port:Int

        var pretty:Bool
        var build:Bool
        var force:Bool

        private
        init(package:PackageIdentifier)
        {
            self.package = package
            self.cookie = ""
            self.remote = "swiftinit.org"
            self.port = 443

            self.pretty = false
            self.build = true
            self.force = false
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

            case "--port", "-p":
                guard
                let port:String = arguments.popFirst(),
                let port:Int = .init(port)
                else
                {
                    fatalError("Expected port number after '\(option)'")
                }

                options.port = port

            case "--pretty", "-P":
                options.pretty = true

            case "--force", "-f":
                options.force = true

            case "--uplink-only", "-u":
                options.build = false

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
    func connect<T>(port:Int, with body:(Connection) async throws -> T) async throws -> T
    {
        try await self.http2.connect(port: port)
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
        port:Int,
        from endpoint:String) async throws -> Response where Response:JSONDecodable
    {
        try await self.connect(port: port) { try await $0.get(from: endpoint) }
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