import HTTPClient
import NIOCore
import NIOPosix
import NIOSSL
import S3
import S3Client
import SemanticVersions
import SwiftinitAssets
import SwiftinitPages
import System

struct Main
{
    private
    var match:String?

    private
    init()
    {
        self.match = nil
    }

    private mutating
    func parse() throws
    {
        var arguments:IndexingIterator<[String]> = Swift.CommandLine.arguments.makeIterator()
        //  Consume name of the executable itself.
        let _:String? = arguments.next()

        while let argument:String = arguments.next()
        {
            if  case nil = self.match
            {
                self.match = argument
            }
            else
            {
                throw OptionsError.unexpected(argument)
            }
        }
    }
}

@main
extension Main
{
    static
    func main() async
    {
        await SystemProcess.do
        {
            @Sendable in

            var main:Self = .init()
            try main.parse()
            try await main.launch()
        }
    }

    private
    func launch() async throws
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

        let s3:AWS.S3.Client = .init(threads: threads,
            niossl: niossl,
            bucket: bucket)

        try await s3.connect
        {
            @Sendable (connection:AWS.S3.Connection) in

            for asset:Swiftinit.Asset in Swiftinit.Asset.allCases
            {
                if  let match:String = self.match, match != "\(asset)"
                {
                    continue
                }

                let content:[UInt8] = try assets.appending(asset.source).read()
                let path:String = asset.path(prepending: Swiftinit.RenderFormat.Assets.version)

                print("Uploading \(path)...")

                try await connection.put(content,
                    using: .standard,
                    path: path,
                    type: asset.type,
                    with: key)
            }
        }
    }
}
