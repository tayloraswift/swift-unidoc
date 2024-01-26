import NIOCore
import NIOHTTP1
import SHA2
import UnixTime

extension AWS.AccessKey
{
    func sign(put content:ByteBuffer,
        storage:AWS.S3.StorageClass,
        bucket:AWS.S3.Bucket,
        path:String) -> HTTPHeaders
    {
        let now:UnixInstant = .now()

        guard
        let timestamp:Timestamp = now.timestamp
        else
        {
            fatalError("Could not get current time.")
        }

        let hash:SHA256 = .init(hashing: content.readableBytesView)
        let date:String = timestamp.http
        let host:String = bucket.domain

        let authorization:String = self.sign(timestamp: timestamp,
            storage: storage,
            bucket: bucket,
            path: path,
            date: date,
            host: host,
            hash: hash)

        let headers:HTTPHeaders =
        [
            "authorization": authorization,

            "date": date,
            "host": host,
            "x-amz-content-sha256": "\(hash)",
            "x-amz-date": "\(timestamp.components.yyyymmddThhmmssZ)",
            "x-amz-storage-class": "\(storage)",
        ]

        return headers
    }

    @_spi(testable)
    public
    func sign(put content:String,
        storage:AWS.S3.StorageClass,
        bucket:AWS.S3.Bucket,
        date:Timestamp,
        path:String) -> String
    {
        self.sign(timestamp: date,
            storage: storage,
            bucket: bucket,
            path: path,
            date: date.http,
            host: bucket.domain,
            hash: .init(hashing: content.utf8))
    }
}
extension AWS.AccessKey
{
    private
    func sign(
        timestamp:Timestamp,
        storage:AWS.S3.StorageClass,
        bucket:AWS.S3.Bucket,
        path:String,
        date:String,
        host:String,
        hash:SHA256) -> String
    {
        let yyyymmddThhmmssZ:String = timestamp.components.yyyymmddThhmmssZ
        let yyyymmdd:String = timestamp.date.yyyymmdd

        let headers:String = "date;host;x-amz-content-sha256;x-amz-date;x-amz-storage-class"
        let request:String = """
        PUT
        \(path)

        date:\(date)
        host:\(host)
        x-amz-content-sha256:\(hash)
        x-amz-date:\(yyyymmddThhmmssZ)
        x-amz-storage-class:\(storage)

        \(headers)
        \(hash)
        """

        let stringToSign:String = """
        AWS4-HMAC-SHA256
        \(yyyymmddThhmmssZ)
        \(yyyymmdd)/\(bucket.region)/s3/aws4_request
        \(SHA256.init(hashing: request.utf8))
        """

        let dateKey:SHA256 = .init(
            authenticating: yyyymmdd.utf8,
            key: "AWS4\(self.secret)".utf8)

        let dateRegionKey:SHA256 = .init(
            authenticating: bucket.region.utf8,
            key: dateKey)

        let dateRegionServiceKey:SHA256 = .init(
            authenticating: "s3".utf8,
            key: dateRegionKey)

        let signingKey:SHA256 = .init(
            authenticating: "aws4_request".utf8,
            key: dateRegionServiceKey)

        let signature:SHA256 = .init(
            authenticating: stringToSign.utf8,
            key: signingKey)

        return """
        AWS4-HMAC-SHA256 \
        Credential=\(self.id)/\(yyyymmdd)/\(bucket.region)/s3/aws4_request,\
        SignedHeaders=\(headers),\
        Signature=\(signature)
        """
    }
}
