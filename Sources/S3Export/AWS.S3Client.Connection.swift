import HTTPClient
import Media
import NIOCore
import NIOHTTP1
import S3

extension AWS.S3Client
{
    @frozen public
    struct Connection
    {
        @usableFromInline internal
        let http1:HTTP1Client.Connection
        @usableFromInline internal
        let bucket:AWS.S3.Bucket
        @usableFromInline internal
        let key:AWS.AccessKey

        @inlinable internal
        init(http1:HTTP1Client.Connection, bucket:AWS.S3.Bucket, key:AWS.AccessKey)
        {
            self.http1 = http1
            self.bucket = bucket
            self.key = key
        }
    }
}
extension AWS.S3Client.Connection
{
    public
    func put(_ content:[UInt8],
        using storage:AWS.S3.StorageClass = .standard,
        path:String,
        type:MediaType) async throws
    {
        try await self.put(self.http1.buffer(bytes: content),
            using: storage,
            path: path,
            type: type)
    }

    private
    func put(_ content:ByteBuffer,
        using storage:AWS.S3.StorageClass,
        path:String,
        type:MediaType) async throws
    {
        var headers:HTTPHeaders = self.key.sign(put: content,
            storage: storage,
            bucket: self.bucket,
            path: path)

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
            fatalError("No status.")
        }

        print("status: \(status)")

        for buffer:ByteBuffer in facet.body
        {
            print(String.init(decoding: buffer.readableBytesView,
                as: Unicode.UTF8.self))
        }
    }
}
