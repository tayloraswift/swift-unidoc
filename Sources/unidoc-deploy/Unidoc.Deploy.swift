import ArgumentParsing
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

extension Unidoc
{
    struct Deploy
    {
        var artifacts:Artifacts
        var secrets:FilePath
        var bucket:String?
        var region:AWS.Region?

        init()
        {
            self.artifacts = .assets(matching: nil)
            self.secrets = "Assets/secrets"
            self.bucket = nil
            self.region = nil
        }
    }
}
@MainActor @main
extension Unidoc.Deploy
{
    static
    func main() async
    {
        do
        {
            var deploy:Self = .init()
            try deploy.parse()
            try await deploy.launch()
        }
        catch let error
        {
            print("Error: \(error)")
            SystemProcess.exit(with: 1)
        }
    }

    private mutating
    func parse() throws
    {
        var arguments:CommandLine.Arguments = .init()

        guard
        let command:String = arguments.next()
        else
        {
            print("No command specified")
            SystemProcess.exit(with: 1)
        }

        switch command
        {
        case "asset":
            break

        case "assets":
            self.artifacts = .assets(matching: arguments.next())

        case "builder":
            self.artifacts = .builder

        default:
            print("Unknown command: \(command)")
            SystemProcess.exit(with: 1)
        }

        while let option:String = arguments.next()
        {
            switch option
            {
            case "--secrets", "-i":
                self.secrets = .init(try arguments.next(for: option))

            case "--bucket", "-b":
                self.bucket = try arguments.next(for: option)

            case "--region", "-r":
                self.region = try arguments.next(for: option)

            default:
                throw CommandLine.ArgumentError.unknown(option)
            }
        }
    }
}

extension Unidoc.Deploy
{
    private
    func launch() async throws
    {
        let threads:MultiThreadedEventLoopGroup = .init(numberOfThreads: 2)
        let niossl:NIOSSLContext = try .init(configuration: .makeClientConfiguration())

        let key:AWS.AccessKey = .init(
            id: try (self.secrets / "aws-access-key-id").readLine(),
            secret: try (self.secrets / "aws-access-key-secret").readLine())

        switch self.artifacts
        {
        case .assets(matching: let name):
            let bucket:AWS.S3.Bucket = .init(
                region: self.region ?? .us_east_1,
                name: self.bucket ?? "swiftinit")

            let s3:AWS.S3.Client = .init(threads: threads,
                niossl: niossl,
                bucket: bucket)

            try await self.exportAssets(matching: name, with: s3, key: key)

        case .builder:
            let bucket:AWS.S3.Bucket = .init(
                region: self.region ?? .ap_south_1,
                name: self.bucket ?? "swiftinit-build")

            let s3:AWS.S3.Client = .init(threads: threads,
                niossl: niossl,
                bucket: bucket)

            try await self.exportBinary(with: s3, key: key)
        }
    }

    private
    func exportAssets(matching name:String?,
        with s3:AWS.S3.Client,
        key:AWS.AccessKey) async throws
    {
        try await s3.connect
        {
            let directory:FilePath = "Assets"
            for asset:Swiftinit.Asset in Swiftinit.Asset.allCases
            {
                if  let name:String = name, name != "\(asset)"
                {
                    continue
                }

                let content:[UInt8] = try directory.appending(asset.source).read()
                let path:String = asset.path(prepending: Unidoc.RenderFormat.Assets.version)

                print("Uploading \(path)...")

                try await $0.put(
                    content: .init(body: .binary(content), type: asset.type),
                    using: .standard,
                    path: path,
                    with: key)
            }
        }
    }

    private
    func exportBinary(
        with s3:AWS.S3.Client,
        key:AWS.AccessKey) async throws
    {
        let path:FilePath = ".build/release/unidoc-build"
        let file:[UInt8] = try path.read()
        try await s3.connect
        {
            print("Uploading unidoc-build...")

            try await $0.put(
                content: .init(body: .binary(file), type: .application(.octet_stream)),
                using: .standard,
                path: "unidoc-build",
                with: key)
        }
    }
}
