import HTTPServer
import MongoDB
import Multiparts
import NIOCore
import NIOHTTP1
import SymbolGraphs
import UnidocDatabase
import URI

extension Delegate
{
    struct PostRequest:Sendable
    {
        let promise:EventLoopPromise<ServerResponse>
        let form:MultipartForm
        let uri:URI

        init(promise:EventLoopPromise<ServerResponse>, form:MultipartForm, uri:URI)
        {
            self.promise = promise
            self.form = form
            self.uri = uri
        }
    }
}
extension Delegate.PostRequest:ServerDelegatePostRequest
{
    init?(_ uri:String,
        address _:SocketAddress?,
        headers:HTTPHeaders,
        body:[UInt8],
        with promise:() -> EventLoopPromise<ServerResponse>)
    {
        if  let uri:URI = .init(uri),
            let type:Substring = headers[canonicalForm: "content-type"].first,
            let type:ContentType = .init(type),
            case .multipart(.formData(boundary: let boundary)) = type
        {
            do
            {
                let form:MultipartForm = try .init(splitting: body, on: boundary)
                self.init(promise: promise(), form: form, uri: uri)
                return
            }
            catch
            {
                return nil
            }
        }
        else
        {
            return nil
        }
    }
}
extension Delegate.PostRequest
{
    func respond(using database:Database,
        in pool:Mongo.SessionPool) async throws -> ServerResponse?
    {
        let display:String?
        switch self.uri.path.normalized() as [String]
        {
        case ["admin", "action", "rebuild"]:
            let session:Mongo.Session = try await .init(from: pool)
            let rebuilt:Int = try await database.rebuild(with: session)
            display = "(rebuilt \(rebuilt) snapshots)"

        case ["admin", "action", "upload"]:
            let session:Mongo.Session = try await .init(from: pool)

            var receipts:[SnapshotReceipt] = []
            for item:MultipartForm.Item in self.form
                where item.header.name == "documentation-binary"
            {
                let docs:Documentation = try .init(buffer: item.value)

                if  let _:String = docs.metadata.id
                {
                    receipts.append(try await database.publish(docs: docs, with: session))
                }
                else
                {
                    throw DocumentationIdentificationError.init()
                }
            }
            display = "\(receipts)"

        case ["admin", "action", "drop-database"]:
            let session:Mongo.Session = try await .init(from: pool)
            try await database.nuke(with: session)
            display = "(reinitialized database)"

        case _:
            display = nil
        }

        if  let display:String
        {
            return .resource(.init(.one(canonical: nil),
                content: .text("success! \(display)"),
                type: .text(.plain, charset: .utf8)))
        }
        else
        {
            return nil
        }
    }
}
