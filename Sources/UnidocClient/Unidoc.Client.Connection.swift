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
        @usableFromInline
        let http:Protocol.Connection
        @usableFromInline
        let authorization:String?

        @inlinable
        init(http:Protocol.Connection, authorization:String?)
        {
            self.http = http
            self.authorization = authorization
        }
    }
}
extension Unidoc.Client<HTTP.Client2>.Connection
{
    public
    func labels() async throws -> Unidoc.BuildLabels?
    {
        do
        {
            //  Server should send a heartbeat every 30 minutes, so we wait for up to
            //  31 minutes.
            return try await self.get(from: "/builder/poll", timeout: .seconds(31 * 60))
        }
        catch is HTTP.NonError
        {
            return nil
        }
    }

    func labels(id:Unidoc.Edition) async throws -> Unidoc.BuildLabels?
    {
        do
        {
            let prompt:Unidoc.BuildLabelsPrompt = .edition(id, force: true)
            return try await self.get(from: "/builder\(prompt.query)", timeout: .seconds(10))
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

    public
    func labels(of package:Symbol.Package,
        series:Unidoc.VersionSeries) async throws -> Unidoc.BuildLabels?
    {
        do
        {
            let prompt:Unidoc.BuildLabelsPrompt = .packageNamed(package,
                series: series,
                force: true)

            return try await self.get(from: "/builder\(prompt.query)", timeout: .seconds(10))
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
}
extension Unidoc.Client<HTTP.Client1>.Connection
{
    func upload(_ unlabeled:SymbolGraphObject<Void>) async throws
    {
        let bson:BSON.Document = .init(encoding: unlabeled)

        print("Uploading local symbol graph...")

        do
        {
            let type:MediaType = .application(.bson)
            let body:ByteBuffer = self.http.buffer(bytes: bson.bytes)

            let request:HTTP.Client1.Request = .init(method: .PUT,
                path: "/builder/\(Unidoc.BuildRoute.labeling)",
                head: [
                    "content-type": "\(type)",
                    "content-length": "\(body.readableBytes)",
                ],
                body: body)

            let response:HTTP.Client1.Facet = try await self.http.fetch(request)

            guard case 204? = response.status
            else
            {
                throw HTTP.StatusError.init(code: response.status,
                    message: .init(decoding: response.body, as: Unicode.UTF8.self))
            }

            print("Successfully uploaded local symbol graph!")
        }
        catch let error
        {
            print("Error: failed to upload local symbol graph!")
            print("Error: \(error)")
            throw error
        }
    }
}
extension Unidoc.Client<HTTP.Client2>.Connection
{
    func upload(_ unlabeled:SymbolGraphObject<Void>) async throws
    {
        let bson:BSON.Document = .init(encoding: unlabeled)

        print("Uploading unlabeled symbol graph...")

        do
        {
            let _:Never = try await self.put(bson: bson,
                to: "/builder/\(Unidoc.BuildRoute.labeling)",
                timeout: .seconds(60))
        }
        catch is HTTP.NonError
        {
            print("Successfully uploaded unlabeled symbol graph!")
        }
        catch let error
        {
            print("Error: failed to upload unlabeled symbol graph!")
            print("Error: \(error)")
            throw error
        }
    }

    func upload(_ artifact:Unidoc.BuildArtifact) async throws
    {
        let bson:BSON.Document = .init(encoding: artifact)

        print("Uploading documentation artifact...")

        do
        {
            let _:Never = try await self.put(bson: bson,
                to: "/builder/\(Unidoc.BuildRoute.labeled)",
                timeout: .seconds(60))
        }
        catch is HTTP.NonError
        {
            print("Successfully uploaded documentation artifact!")
        }
        catch let error
        {
            print("Error: failed to upload documentation artifact!")
            print("Error: \(error)")
            throw error
        }
    }

    func upload(_ report:Unidoc.BuildReport) async throws
    {
        let bson:BSON.Document = .init(encoding: report)
        do
        {
            let _:Never = try await self.put(bson: bson,
                to: "/builder/\(Unidoc.BuildRoute.report)")
        }
        catch is HTTP.NonError
        {
            print("Reported build entered stage: \(report.entered)")
        }
        catch let error
        {
            print("Error: failed to upload build report!")
            print("Error: \(error)")
            throw error
        }
    }
}

extension Unidoc.Client<HTTP.Client2>.Connection
{
    private
    func headers(_ method:String, _ endpoint:String) -> HPACKHeaders
    {
        var headers:HPACKHeaders =
        [
            ":method": method,
            ":scheme": "https",
            ":authority": self.http.remote,
            ":path": endpoint,

            "user-agent": "UnidocBuild",
            "accept": "application/json",
        ]

        if  let authorization:String = self.authorization
        {
            headers.add(name: "authorization", value: "Unidoc \(authorization)")
        }

        return headers
    }
}
extension Unidoc.Client<HTTP.Client2>.Connection
{
    @discardableResult
    func post(urlencoded:consuming String, to endpoint:String) async throws -> [UInt8]
    {
        try await self.fetch(endpoint, method: "POST",
            body: self.http.buffer(string: urlencoded),
            type: .application(.x_www_form_urlencoded))
    }

    @discardableResult
    func put(bson:consuming BSON.Document,
        to endpoint:String,
        timeout:Duration = .seconds(15)) async throws -> [UInt8]
    {
        try await self.fetch(endpoint,
            method: "PUT",
            body: self.http.buffer(bytes: bson.bytes),
            type: .application(.bson),
            timeout: timeout)
    }

    func put<Response>(bson:consuming BSON.Document,
        to endpoint:String,
        timeout:Duration = .seconds(15),
        expecting _:Response.Type = Response.self) async throws -> Response
        where Response:JSONDecodable
    {
        let json:JSON = .init(
            utf8: try await self.put(bson: bson, to: endpoint, timeout: timeout)[...])

        return try json.decode()
    }

    func get<Response>(_:Response.Type = Response.self,
        from endpoint:String,
        timeout:Duration) async throws -> Response
        where Response:JSONDecodable
    {
        let json:JSON = .init(
            utf8: try await self.fetch(endpoint, method: "GET", timeout: timeout)[...])

        return try json.decode()
    }
}
extension Unidoc.Client<HTTP.Client2>.Connection
{
    func fetch(_ endpoint:String,
        method:String,
        body:ByteBuffer? = nil,
        type:MediaType? = nil,
        timeout:Duration = .seconds(15)) async throws -> [UInt8]
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

            let response:HTTP.Client2.Facet = try await self.http.fetch(.init(
                    headers: headers,
                    body: body),
                timeout: timeout)

            switch response.status
            {
            case 200?, 201?, 202?, 203?:
                return response.body

            case 204?:
                throw HTTP.NonError.init()

            case 301?:
                if  let location:String = response.headers?["location"].first
                {
                    endpoint = .init(location.trimmingPrefix("https://\(self.http.remote)"))
                    continue following
                }
            case _:
                message = .init(decoding: response.body, as: Unicode.UTF8.self)
                break
            }

            status = response.status
            break following
        }

        throw HTTP.StatusError.init(code: status, message: message)
    }
}
