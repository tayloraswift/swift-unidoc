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
    func put(_ content:[UInt8],
        using storage:AWS.S3.StorageClass = .standard,
        path:String,
        type:MediaType,
        with key:AWS.AccessKey? = nil) async throws
    {
        try await self.put(self.http1.buffer(bytes: content),
            using: storage,
            path: path,
            type: type,
            with: key)
    }

    private
    func put(_ content:ByteBuffer,
        using storage:AWS.S3.StorageClass,
        path:String,
        type:MediaType,
        with key:AWS.AccessKey?) async throws
    {
        var headers:HTTPHeaders = key?.sign(put: content,
            storage: storage,
            bucket: self.bucket,
            path: path) ?? ["host": bucket.domain]

        headers.add(name: "content-length", value: "\(content.readableBytes)")
        headers.add(name: "content-type", value: "\(type)")

        let facet:HTTP1Client.Facet = try await self.http1.fetch(.init(
            method: .PUT,
            path: path,
            head: headers,
            body: content))

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
