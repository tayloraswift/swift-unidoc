import ArgumentParser
import HTTP
import NIOCore
import NIOPosix
import NIOSSL
import S3
import S3Client
import System_
import Unidoc
import UnidocAssets_System

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

        let key:AWS.AccessKey = .init(id: "AKIAW6WXTH6AJNFIOYV6", secret: self.secret)
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
        let archive:FilePath = release / "\(name).tar.gz"

        print("Compressing \(name)...")

        var arguments:[String] = [
            "-czf", "\(archive)",
            "-C", ".",
        ]

        let assets:FilePath.Directory = "Assets"
        for asset:Unidoc.Asset in [
            .main_css,
            .main_css_map,
            .main_js,
            .main_js_map,
            .literata45_woff2,
            .literata47_woff2,
            .literata75_woff2,
            .literata77_woff2
        ]
        {
            arguments.append("\(assets.path.appending(asset.source))")
        }
        //  This needs to come after the `.` location, as each `-C` is relative to the last.
        arguments.append("-C")
        arguments.append("\(release)")
        arguments.append(name)

        try SystemProcess.init(command: "tar", arguments: arguments, echo: true)()
        let file:[UInt8] = try archive.read()

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
                path: "\(path).tar.gz",
                with: key,
                timeout: .seconds(1200))
        }
    }
}
