import HTTPClient
import NIOPosix
import NIOSSL
import S3

extension AWS.S3
{
    /// An S3 client is just an HTTP/1.1 client with an associated bucket.
    ///
    /// If you have multiple buckets, you will need multiple clients, because Amazon today
    /// serves different buckets from different domains.
    ///
    /// Most of the S3 methods are implemented on ``Connection``. Obtain a connection by calling
    /// the ``connect(with:)`` method on the client.
    @frozen public
    struct Client
    {
        @usableFromInline
        let bucket:AWS.S3.Bucket
        @usableFromInline
        let http1:HTTP.Client1

        @inlinable
        init(bucket:AWS.S3.Bucket, http1:HTTP.Client1)
        {
            self.http1 = http1
            self.bucket = bucket
        }
    }
}
extension AWS.S3.Client
{
    @inlinable public
    init(threads:MultiThreadedEventLoopGroup, niossl:NIOSSLContext, bucket:AWS.S3.Bucket)
    {
        self.init(bucket: bucket,
            http1: .init(threads: threads,
                niossl: niossl,
                remote: bucket.domain))
    }
}
extension AWS.S3.Client
{
    @inlinable public
    func connect<T>(with body:(AWS.S3.Connection) async throws -> T) async throws -> T
    {
        try await self.http1.connect
        {
            try await body(AWS.S3.Connection.init(bucket: self.bucket, http1: $0))
        }
    }
}
