import ArgumentParser
import SystemIO
import System_ArgumentParser

extension SSGC
{
    public
    struct BuildOptions:ParsableArguments
    {
        @Option(
            name: [.customLong("swift-toolchain"), .customShort("u")],
            help: "The path to a Swift toolchain directory, usually ending in 'usr'",
            completion: .directory)
        var swiftTools:FilePath.Directory?

        @Option(
            name: [.customLong("swiftpm-cache")],
            help: "The path to the SwiftPM cache directory to use",
            completion: .directory)
        var swiftCache:FilePath.Directory?

        @Option(
            name: [.customLong("sdk"), .customShort("k")],
            help: "The Apple SDK to use")
        var appleSDK:AppleSDK? = nil

        @Flag(
            name: [.customLong("pretty")],
            help: """
                Tell lib/SymbolGraphGen to pretty-print the JSON output, if possible
                """)
        var pretty:Bool = false


        @Option(
            name: [.customLong("output"), .customShort("o")],
            help: "The path to write the compiled symbol graph to")
        var output:FilePath? = nil

        @Option(
            name: [.customLong("output-log"), .customShort("l")],
            help: "The path to write the log of the build process to")
        var outputLog:FilePath? = nil


        @Option(
            name: [.customLong("project-name"), .customShort("n")],
            help: """
                The symbolic name of the project to build — \
                this is not the name specified in the `Package.swift` manifest!
                """)
        var projectName:String?

        @Option(
            name: [.customLong("project-type"), .customShort("b")],
            help: "The type of project to build as")
        var projectType:ProjectType = .package


        @Option(
            name: [.customLong("define"), .customShort("D")],
            parsing: .unconditionalSingleValue,
            help: "Define a trait for the Documentation compiler")
        var defines:[String] = []

        @Option(
            name: [.customLong("Xswiftc")],
            parsing: .unconditionalSingleValue,
            help: "Extra flags to pass to the Swift compiler")
        var swiftc:[String] = []

        @Option(
            name: [.customLong("Xcxx")],
            parsing: .unconditionalSingleValue,
            help: "Extra flags to pass to the C++ compiler")
        var cxx:[String] = []

        @Option(
            name: [.customLong("Xcc")],
            parsing: .unconditionalSingleValue,
            help: "Extra flags to pass to the C compiler")
        var cc:[String] = []

        @Option(
            name: [.customLong("ci")],
            help: "Run in CI mode under the specified validation level")
        var ci:ValidationBehavior? = nil

        public
        init()
        {
        }
    }
}
extension SSGC.BuildOptions
{
    var toolchain:SSGC.Toolchain
    {
        get throws
        {
            try .detect(appleSDK: self.appleSDK,
                paths: .init(swiftPM: self.swiftCache, usr: self.swiftTools),
                recoverFromAppleBugs: true, // self.recoverFromAppleBugs,
                pretty: self.pretty)
        }
    }

    var flags:SSGC.PackageBuild.Flags
    {
        .init(swift: self.swiftc, cxx: self.cxx, c: self.cc)
    }
}
