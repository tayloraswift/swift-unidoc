import HTTPClient
import Media
import NIOCore
import NIOHTTP1
import S3

extension AWS.S3
{
    /// Provides the API for interacting with an AWS S3 bucket.
    ///
    /// The basic S3 object manipulations are ``put(content:using:path:with:timeout:)``,
    /// ``get(path:timeout:)``, and ``delete(path:)``. Of the three, only the PUT method
    /// currently supports authentication with an access key.
    ///
    /// It should be possible to implement authenticated access for GET and DELETE, but we have
    /// not gotten around to it yet. In particular, it is uncommon to GET S3 objects directly
    /// from a bucket to an untrusted machine; this access pattern is better suited for a
    /// service like Amazon CloudFront.
    ///
    /// >   Note:
    ///     We would never be running an S3 server ourselves, so we don’t need to namespace
    ///     this type under ``Client``.
    @frozen public
    struct Connection
    {
        @usableFromInline internal
        let bucket:AWS.S3.Bucket
        @usableFromInline internal
        let http1:HTTP.Client1.Connection

        @inlinable internal
        init(bucket:AWS.S3.Bucket, http1:HTTP.Client1.Connection)
        {
            self.bucket = bucket
            self.http1 = http1
        }
    }
}
extension AWS.S3.Connection
{
    public
    func put(object content:HTTP.Resource.Content,
        using storage:AWS.S3.StorageClass = .standard,
        path:String,
        with key:AWS.AccessKey? = nil,
        timeout:Duration = .seconds(15)) async throws
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

        let response:HTTP.Client1.Facet = try await self.http1.fetch(.init(
                method: .PUT,
                path: path,
                head: headers,
                body: body),
            timeout: timeout)

        switch response.status
        {
        case 200?:
            return

        case let status:
            throw AWS.S3.RequestError.put(status ?? 0, String.init(
                decoding: response.body,
                as: Unicode.UTF8.self))
        }
    }

    public
    func get(path:String, timeout:Duration = .seconds(15)) async throws -> [UInt8]
    {
        let response:HTTP.Client1.Facet = try await self.http1.fetch(.init(
                method: .GET,
                path: path,
                head: ["host": bucket.domain]),
            timeout: timeout)

        switch response.status
        {
        case 200?:
            return response.body

        case let status:
            throw AWS.S3.RequestError.get(status ?? 0, String.init(
                decoding: response.body,
                as: Unicode.UTF8.self))
        }
    }

    public
    func delete(path:String) async throws -> Bool
    {
        let response:HTTP.Client1.Facet = try await self.http1.fetch(.init(
                method: .DELETE,
                path: path,
                head: ["host": bucket.domain]),
            timeout: .seconds(15))

        switch response.status
        {
        case 200?, 204?:
            return true

        case 404?:
            return false

        case let status:
            throw AWS.S3.RequestError.delete(status ?? 0, String.init(
                decoding: response.body,
                as: Unicode.UTF8.self))
        }
    }
}
