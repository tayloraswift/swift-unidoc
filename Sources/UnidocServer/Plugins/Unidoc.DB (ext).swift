import MongoDB
import S3Client
import UnidocDB

extension Unidoc.DB
{
    func uplink(_ edition:Unidoc.Edition,
        from s3:AWS.S3.Client?,
        with session:Mongo.Session) async throws -> Unidoc.UplinkStatus?
    {
        guard
        let s3:AWS.S3.Client
        else
        {
            return try await self.uplink(edition,
                loader: nil as AWS.S3.GraphLoader?,
                with: session)
        }

        return try await s3.connect
        {
            try await self.uplink(edition,
                loader: AWS.S3.GraphLoader.init(s3: $0),
                with: session)
        }
    }
}
