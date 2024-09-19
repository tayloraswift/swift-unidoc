import ArgumentParser
import HTTP
import NIOPosix
import SymbolGraphCompiler
import System_
import UnidocClient

extension Main
{
    struct Local
    {
        @Argument
        var project:String

        @Option(
            name: [.customLong("host"), .customShort("h")],
            help: "The name of a host running a compatible instance of unidoc-preview")
        var host:String = "localhost"

        @Option(
            name: [.customLong("port"), .customShort("p")],
            help: "The number of a port bound to a compatible instance of unidoc-preview")
        var port:Int  = 8080

        @Option(
            name: [.customLong("swift-toolchain"), .customShort("u")],
            help: "The path to a Swift toolchain directory, usually ending in 'usr'",
            completion: .directory)
        var toolchain:FilePath.Directory?

        @Option(
            name: [.customLong("swift-sdk"), .customShort("k")],
            help: "The Swift SDK to use")
        var sdk:SSGC.AppleSDK?

        @Option(
            name: [.customLong("input"), .customShort("I")],
            help: "The path to a directory containing the project to build",
            completion: .directory)
        var input:FilePath.Directory?


        @Flag(
            name: [.customLong("pretty"), .customShort("o")],
            help: "Tell lib/SymbolGraphGen to pretty-print the JSON output, if possible")
        var pretty:Bool = false

        @Flag(
            name: [.customLong("book"), .customShort("b")],
            help: "Build a local book project")
        var book:Bool = false
    }
}
extension Main.Local:AsyncParsableCommand
{
    static let configuration:CommandConfiguration = .init(commandName: "local")

    mutating
    func run() async throws
    {
        let threads:MultiThreadedEventLoopGroup = .init(numberOfThreads: 2)

        #if os(macOS)

        //  Guess the SDK if not specified.
        self.sdk = self.sdk ?? .macOS

        #endif

        let toolchain:Unidoc.Toolchain = .init(
            usr: self.toolchain,
            sdk: self.sdk)

        let unidoc:Unidoc.Client<HTTP.Client1> = .init(authorization: nil,
            pretty: self.pretty,
            http: .init(threads: threads, niossl: nil, remote: self.host),
            port: self.port)

        print("Connecting to \(self.host):\(self.port)...")

        try await unidoc.buildAndUpload(local: self.project,
            search: self.input,
            type: self.book ? .book : .package,
            with: toolchain)
    }
}
