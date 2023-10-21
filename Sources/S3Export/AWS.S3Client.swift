import HTTPClient
import S3

extension AWS
{
    @frozen public
    struct S3Client
    {
        @usableFromInline internal
        let http1:HTTP1Client

        @usableFromInline internal
        let bucket:S3.Bucket
        @usableFromInline internal
        let key:AccessKey

        @inlinable public
        init(http1:HTTP1Client, bucket:S3.Bucket, key:AccessKey)
        {
            self.http1 = http1

            self.bucket = bucket
            self.key = key
        }
    }
}
extension AWS.S3Client
{
    @inlinable public
    func connect<T>(with body:(Connection) async throws -> T) async throws -> T
    {
        try await self.http1.connect
        {
            try await body(Connection.init(http1: $0, bucket: self.bucket, key: self.key))
        }
    }
}
