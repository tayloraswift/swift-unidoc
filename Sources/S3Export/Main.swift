import HTTPClient
import NIOCore
import NIOPosix
import NIOSSL
import S3
import SemanticVersions
import SwiftinitAssets
import SwiftinitPages
import System

@main
enum Main
{
    static
    func main() async throws
    {
        let threads:MultiThreadedEventLoopGroup = .init(numberOfThreads: 2)
        let niossl:NIOSSLContext = try .init(configuration: .makeClientConfiguration())
        let bucket:AWS.S3.Bucket = .init(region: .us_east_1, name: "swiftinit")

        let assets:FilePath = "Assets"
        let key:AWS.AccessKey
        do
        {
            key = .init(id: try (assets / "secrets" / "aws-access-key-id").readLine(),
                secret: try (assets / "secrets" / "aws-access-key-secret").readLine())
        }
        catch
        {
            fatalError("could not load AWS access key!")
        }

        let s3:AWS.S3Client = .init(
            http1: .init(threads: threads,
                niossl: niossl,
                remote: "\(bucket.name).s3.amazonaws.com"),
            bucket: bucket,
            key: key)

        try await s3.connect
        {
            @Sendable (connection:AWS.S3Client.Connection) in

            for asset:Swiftinit.Asset in Swiftinit.Asset.allCases
            {
                let content:[UInt8] = try assets.appending(asset.source).read()
                let path:String = asset.path(prepending: Swiftinit.RenderFormat.Assets.version)

                print("Uploading \(path)...")

                try await connection.put(content,
                    using: .standard,
                    path: path,
                    type: asset.type)
            }
        }
    }
}
