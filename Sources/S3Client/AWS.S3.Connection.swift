import HTTPClient
import Media
import NIOCore
import NIOHTTP1
import S3

extension AWS.S3
{
    /// We would never be running an S3 server ourselves, so we don’t need to namespace this.
    @frozen public
    struct Connection
    {
        @usableFromInline internal
        let bucket:AWS.S3.Bucket
        @usableFromInline internal
        let http1:HTTP1Client.Connection

        @inlinable internal
        init(bucket:AWS.S3.Bucket, http1:HTTP1Client.Connection)
        {
            self.bucket = bucket
            self.http1 = http1
        }
    }
}
extension AWS.S3.Connection
{
    public
    func put(content:HTTP.Resource.Content,
        using storage:AWS.S3.StorageClass = .standard,
        path:String,
        with key:AWS.AccessKey? = nil) async throws
    {
        let body:ByteBuffer = self.http1.buffer(content.body)

        var headers:HTTPHeaders = key?.sign(put: body,
            storage: storage,
            bucket: self.bucket,
            path: path) ?? ["host": bucket.domain]

        headers.add(name: "content-length", value: "\(body.readableBytes)")
        headers.add(name: "content-type", value: "\(content.type)")

        if  let encoding:MediaEncoding = content.encoding
        {
            headers.add(name: "content-encoding", value: "\(encoding)")
        }

        let facet:HTTP1Client.Facet = try await self.http1.fetch(.init(
            method: .PUT,
            path: path,
            head: headers,
            body: body))

        guard
        let status:HTTPResponseStatus = facet.head?.status
        else
        {
            throw AWS.S3.RequestError.put(0)
        }
        guard
        case .ok = status
        else
        {
            throw AWS.S3.RequestError.put(status.code)
        }
    }

    public
    func get(path:String) async throws -> [UInt8]
    {
        let facet:HTTP1Client.Facet = try await self.http1.fetch(.init(
            method: .GET,
            path: path,
            head: ["host": bucket.domain]))

        guard
        let status:HTTPResponseStatus = facet.head?.status
        else
        {
            throw AWS.S3.RequestError.get(0)
        }
        guard
        case .ok = status
        else
        {
            throw AWS.S3.RequestError.get(status.code)
        }

        return facet.body
    }

    public
    func delete(path:String) async throws -> Bool
    {
        let facet:HTTP1Client.Facet = try await self.http1.fetch(.init(
            method: .DELETE,
            path: path,
            head: ["host": bucket.domain]))

        guard
        let status:HTTPResponseStatus = facet.head?.status
        else
        {
            throw AWS.S3.RequestError.delete(0)
        }

        switch status
        {
        case .ok:           return true
        case .noContent:    return true
        case .notFound:     return false
        case let status:
            throw AWS.S3.RequestError.delete(status.code)
        }
    }
}
