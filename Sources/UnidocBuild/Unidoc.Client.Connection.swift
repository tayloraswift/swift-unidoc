import BSON
import HTTPClient
import JSON
import Media
import NIOCore
import NIOHPACK
import SemanticVersions
import SymbolGraphs
import Symbols
import UnidocAPI
import UnidocRecords
import URI

extension Unidoc.Client
{
    @frozen public
    struct Connection
    {
        @usableFromInline internal
        let http2:HTTP2Client.Connection
        @usableFromInline internal
        let cookie:String

        @inlinable internal
        init(http2:HTTP2Client.Connection, cookie:String)
        {
            self.http2 = http2
            self.cookie = cookie
        }
    }
}

extension Unidoc.Client.Connection
{
    func oldest(until abi:PatchVersion) async throws -> [Unidoc.Edition]
    {
        let prompt:Unidoc.BuildLabelsPrompt = ._allSymbolGraphs(upTo: abi, limit: 16)
        return try await self.get(from: "/ssgc\(prompt.query)", timeout: .seconds(10))
    }

    func build(id:Unidoc.Edition) async throws -> Unidoc.BuildLabels
    {
        let prompt:Unidoc.BuildLabelsPrompt = .edition(id)
        return try await self.get(from: "/ssgc\(prompt.query)", timeout: .seconds(10))
    }

    func latest(_ force:Unidoc.VersionSeries?,
        of package:Symbol.Package) async throws -> Unidoc.BuildLabels
    {
        let prompt:Unidoc.BuildLabelsPrompt = .packageNamed(package, series: force)
        return try await self.get(from: "/ssgc\(prompt.query)", timeout: .seconds(10))
    }

    func upload(_ unlabeled:consuming SymbolGraphObject<Void>) async throws
    {
        let bson:BSON.Document = .init(encoding: unlabeled)

        print("Uploading unlabeled symbol graph...")

        let _:Unidoc.UploadStatus = try await self.put(bson: bson,
            to: "/ssgc/\(Unidoc.BuildOutcome.successUnlabeled)")

        print("Successfully uploaded symbol graph!")
    }

    func upload(_ labeled:consuming Unidoc.Snapshot) async throws
    {
        let bson:BSON.Document = .init(encoding: labeled)

        print("Uploading labeled symbol graph...")

        let _:Unidoc.UploadStatus = try await self.put(bson: bson,
            to: "/ssgc/\(Unidoc.BuildOutcome.success)")

        print("Successfully uploaded symbol graph!")
    }

    func upload(_ report:consuming Unidoc.BuildFailureReport) async throws
    {
        let bson:BSON.Document = .init(encoding: report)

        print("Uploading build failure report...")

        let _:Unidoc.UploadStatus = try await self.put(bson: bson,
            to: "/ssgc/\(Unidoc.BuildOutcome.failure)")

        print("Successfully uploaded build failure report!")
    }
}

extension Unidoc.Client.Connection
{
    @inlinable internal
    func headers(_ method:String, _ endpoint:String) -> HPACKHeaders
    {
        [
            ":method": method,
            ":scheme": "https",
            ":authority": self.http2.remote,
            ":path": endpoint,

            "user-agent": "UnidocBuild",
            "accept": "application/json",
            "cookie": "__Host-session=\(self.cookie)",
        ]
    }
}
extension Unidoc.Client.Connection
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
    func put<Response>(bson:consuming BSON.Document,
        to endpoint:String,
        expecting _:Response.Type = Response.self) async throws -> Response
        where Response:JSONDecodable
    {
        var json:JSON = .init(utf8: [])

        for buffer:ByteBuffer in try await self.put(bson: bson, to: endpoint)
        {
            json.utf8 += buffer.readableBytesView
        }

        return try json.decode()
    }

    @inlinable public
    func get<Response>(_:Response.Type = Response.self,
        from endpoint:String,
        timeout:Duration) async throws -> Response
        where Response:JSONDecodable
    {
        var json:JSON = .init(utf8: [])

        for buffer:ByteBuffer in try await self.fetch(endpoint, method: "GET", timeout: timeout)
        {
            json.utf8 += buffer.readableBytesView
        }

        return try json.decode()
    }
}
extension Unidoc.Client.Connection
{
    @inlinable internal
    func fetch(_ endpoint:String,
        method:String,
        body:ByteBuffer? = nil,
        type:MediaType? = nil,
        timeout:Duration = .seconds(15)) async throws -> [ByteBuffer]
    {
        var endpoint:String = endpoint
        var message:String = ""
        var status:UInt? = nil

        following:
        for _:Int in 0 ... 1
        {
            var headers:HPACKHeaders = self.headers(method, endpoint)
            if  let type:MediaType
            {
                headers.add(name: "content-type", value: "\(type)")
            }
            if  let body:ByteBuffer
            {
                headers.add(name: "content-length", value: "\(body.readableBytes)")
            }

            let response:HTTP2Client.Facet = try await self.http2.fetch(.init(
                    headers: headers,
                    body: body),
                timeout: timeout)

            switch response.status
            {
            case 200?:
                return response.buffers

            case 301?:
                if  let location:String = response.headers?["location"].first
                {
                    endpoint = .init(location.trimmingPrefix("https://\(self.http2.remote)"))
                    continue following
                }
            case _:
                message = response.buffers.reduce(into: "")
                {
                    $0 += String.init(decoding: $1.readableBytesView, as: Unicode.UTF8.self)
                }
                break
            }

            status = response.status
            break following
        }

        throw HTTP.StatusError.init(code: status, message: message)
    }
}
