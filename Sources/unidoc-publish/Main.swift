import ArgumentParser
import HTTP
import NIOCore
import NIOPosix
import NIOSSL
import S3
import S3Client
import System

struct Main
{
    @Argument
    var binary:String

    @Argument
    var target:String

    @Option(
        name: [.customLong("secret"), .customShort("i")],
        help: "AWS access key secret")
    var secret:String

    init()
    {
    }
}

@main
extension Main:AsyncParsableCommand
{
    func run() async throws
    {
        let threads:MultiThreadedEventLoopGroup = .init(numberOfThreads: 2)
        let niossl:NIOSSLContext = try .init(configuration: .makeClientConfiguration())

        let key:AWS.AccessKey = .init(id: "AKIAW6WXTH6AKEVUNFUY", secret: self.secret)
        let bucket:AWS.S3.Bucket = .init(region: .us_east_1, name: "swiftinit")

        let s3:AWS.S3.Client = .init(threads: threads,
            niossl: niossl,
            bucket: bucket)

        try await s3.export(binary: self.binary,
            from: ".build",
            with: key,
            as: self.target)
    }
}
extension AWS.S3.Client
{
    func export(binary name:String,
        from scratch:FilePath.Directory,
        with key:AWS.AccessKey,
        as path:String) async throws
    {
        let release:FilePath.Directory = scratch / "release"
        let executable:FilePath = release / name
        let compressed:FilePath = release / "\(name).gz"

        print("Compressing \(name)...")

        try SystemProcess.init(command: "gzip", "-kf", "\(executable)")()
        let file:[UInt8] = try compressed.read()

        try await self.connect
        {
            print("Uploading \(name)...")
            let object:HTTP.Resource.Content = .init(
                body: .binary(file),
                type: .application(.octet_stream),
                encoding: .gzip)
            //  These could be big files, even compressed, so we need to increase the timeout.
            try await $0.put(object: object,
                using: .standard,
                path: "\(path).gz",
                with: key,
                timeout: .seconds(1200))
        }
    }
}