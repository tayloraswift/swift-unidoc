import ArgumentParser
import HTTP
import SymbolGraphCompiler
import Symbols
import System

extension Main
{
    struct Local
    {
        @Argument
        var project:Symbol.Package

        @Option(
            name: [.customLong("host"), .customShort("h")],
            help: "The name of a host running a compatible instance of unidoc-preview")
        var host:String = "localhost"

        @Option(
            name: [.customLong("port"), .customShort("p")],
            help: "The number of a port bound to a compatible instance of unidoc-preview")
        var port:Int  = 8080

        @Option(
            name: [.customLong("swift-runtime"), .customShort("r")],
            help: "The path to the Swift runtime directory, usually ending in /usr/lib",
            completion: .directory)
        var swiftRuntime:String?

        @Option(
            name: [.customLong("swift"), .customShort("s")],
            help: "The path to the Swift toolchain",
            completion: .file(extensions: []))
        var swiftPath:String?

        @Option(
            name: [.customLong("swift-sdk"), .customShort("k")],
            help: "The Swift SDK to use")
        var swiftSDK:SSGC.AppleSDK?

        @Option(
            name: [.customLong("input"), .customShort("I")],
            help: "The path to a directory containing the project to build",
            completion: .directory)
        var input:String?


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
        #if os(macOS)

        //  Guess the SDK if not specified.
        self.swiftSDK = self.swiftSDK ?? .macOS

        #endif

        let search:FilePath? = self.input.map(FilePath.init(_:))
        let type:SSGC.ProjectType = self.book ? .book : .package
        let unidoc:Unidoc.Client<HTTP.Client1> = try .init(from: self)
        try await unidoc.buildAndUpload(local: self.project, search: search, type: type)
    }
}
