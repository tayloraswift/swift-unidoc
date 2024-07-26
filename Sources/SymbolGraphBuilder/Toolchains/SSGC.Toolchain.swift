#if canImport(IndexStoreDB)

import class IndexStoreDB.IndexStoreLibrary

#endif

import JSON
import PackageMetadata
import SemanticVersions
import SymbolGraphs
import Symbols
import System

extension SSGC
{
    @frozen public
    struct Toolchain
    {
        /// A path to a specific Swift toolchain to use, or just the string `"swift"`.
        private
        let swiftCommand:String
        /// A path to the Swift runtime directory to load the `libIndexStore.{so, dylib}` from.
        private
        let swiftRuntime:FilePath.Directory?
        /// A path to the SwiftPM cache directory to use.
        private
        let swiftCache:FilePath.Directory?
        private
        let swiftSDK:AppleSDK?

        /// What to name the scratch directory.
        public
        let scratch:FilePath.Component

        public
        let version:SwiftVersion
        public
        let commit:SymbolGraphMetadata.Commit?
        public
        let triple:Triple

        private
        let pretty:Bool

        private
        init(swiftCommand:String,
            swiftRuntime:FilePath.Directory?,
            swiftCache:FilePath.Directory?,
            swiftSDK:AppleSDK?,
            scratch:FilePath.Component,
            version:SwiftVersion,
            commit:SymbolGraphMetadata.Commit?,
            triple:Triple,
            pretty:Bool)
        {
            self.swiftCommand = swiftCommand
            self.swiftRuntime = swiftRuntime
            self.swiftCache = swiftCache
            self.swiftSDK = swiftSDK
            self.scratch = scratch
            self.version = version
            self.commit = commit
            self.triple = triple
            self.pretty = pretty
        }
    }
}
extension SSGC.Toolchain
{
    public
    init(parsing splash:String,
        swiftCommand:String = "swift",
        swiftRuntime:FilePath.Directory? = nil,
        swiftCache:FilePath.Directory? = nil,
        swiftSDK:SSGC.AppleSDK? = nil,
        scratch:FilePath.Component = ".build.ssgc",
        pretty:Bool = false) throws
    {
        //  Splash should consist of two complete lines and a final newline. If the final
        //  newline isn’t present, the output was clipped.
        let lines:[Substring] = splash.split(separator: "\n", omittingEmptySubsequences: false)
        guard lines.count == 3
        else
        {
            throw SSGC.ToolchainError.malformedSplash
        }

        let toolchain:[Substring] = lines[0].split(separator: " ")
        let triple:[Substring] = lines[1].split(separator: " ")

        guard
            triple.count == 2,
            triple[0] == "Target:",
        let triple:Triple = .init(triple[1])
        else
        {
            throw SSGC.ToolchainError.malformedSplash
        }

        var k:Int = toolchain.endIndex
        for (i, j):(Int, Int) in zip(toolchain.indices, toolchain.indices.dropFirst())
        {
            if  toolchain[i ... j] == ["Swift", "version"]
            {
                k = toolchain.index(after: j)
                break
            }
        }
        if  k == toolchain.endIndex
        {
            throw SSGC.ToolchainError.malformedSplash
        }

        let swift:SwiftVersion
        if  let version:NumericVersion = .init(toolchain[k])
        {
            swift = .init(version: PatchVersion.init(padding: version))
        }

        else if
            let version:MinorVersion = .init(toolchain[k].prefix { $0 != "-" })
        {
            swift = .init(
                version: .v(version.components.major, version.components.minor, 0),
                nightly: .DEVELOPMENT_SNAPSHOT)
        }
        else
        {
            throw SSGC.ToolchainError.malformedSwiftVersion
        }

        let commit:SymbolGraphMetadata.Commit?
        if  case nil = swift.nightly,
            let word:Substring = toolchain[toolchain.index(after: k)...].first
        {
            commit = .parenthesizedSwiftRelease(word)
        }
        else
        {
            commit = nil
        }

        self.init(
            swiftCommand: swiftCommand,
            swiftRuntime: swiftRuntime,
            swiftCache: swiftCache,
            swiftSDK: swiftSDK,
            scratch: scratch,
            version: swift,
            commit: commit,
            triple: triple,
            pretty: pretty)
    }

    public static
    func detect(
        swiftRuntime:FilePath.Directory? = nil,
        swiftCache:FilePath.Directory? = nil,
        swiftPath:FilePath? = nil,
        swiftSDK:SSGC.AppleSDK? = nil,
        pretty:Bool = false) throws -> Self
    {
        let (readable, writable):(FileDescriptor, FileDescriptor) = try FileDescriptor.pipe()

        defer
        {
            try? writable.close()
            try? readable.close()
        }

        let swift:String = swiftPath?.string ?? "swift"

        try SystemProcess.init(command: swift, "--version", stdout: writable)()
        return try .init(parsing: try readable.read(buffering: 1024),
            swiftCommand: swift,
            swiftRuntime: swiftRuntime,
            swiftCache: swiftCache,
            swiftSDK: swiftSDK,
            pretty: pretty)
    }
}
extension SSGC.Toolchain
{
    #if canImport(IndexStoreDB)

    func libIndexStore() throws -> IndexStoreLibrary
    {
        let libraries:FilePath.Directory
        let library:FilePath

        #if os(macOS)

            libraries = self.swiftRuntime ?? """
            /Applications/Xcode.app/Contents/Developer/Toolchains\
            /XcodeDefault.xctoolchain/usr/lib
            """
            library = libraries / "libIndexStore.dylib"

        #else

            libraries = self.swiftRuntime ?? "/usr/lib"
            library = libraries / "libIndexStore.so"

        #endif

        return try .init(dylibPath: "\(library)")
    }

    #endif

    func platform() throws -> SymbolGraphMetadata.Platform
    {
        if      self.triple.os.starts(with: "linux")
        {
            return .linux
        }
        else if self.triple.os.starts(with: "ios")
        {
            return .iOS
        }
        else if self.triple.os.starts(with: "macos")
        {
            return .macOS
        }
        else if self.triple.os.starts(with: "tvos")
        {
            return .tvOS
        }
        else if self.triple.os.starts(with: "watchos")
        {
            return .watchOS
        }
        else if self.triple.os.starts(with: "windows")
        {
            return .windows
        }
        else
        {
            throw SSGC.ToolchainError.unsupportedTriple(self.triple)
        }
    }
}

extension SSGC.Toolchain
{
    func manifest(package:FilePath.Directory,
        json file:FilePath,
        leaf:Bool) throws -> SPM.Manifest
    {
        //  The manifest can be very large, possibly larger than the 64 KB pipe buffer
        //  limit. So instead of getting the `dump-package` output from a pipe, we
        //  tell the subprocess to write it to a file, and read back the file afterwards.
        let json:JSON
        do
        {
            let utf8:[UInt8] = try file.open(.readWrite,
                permissions: (.rw, .r, .r),
                options: [.create, .truncate])
            {
                let dump:SystemProcess = try .init(command: self.swiftCommand,
                    "package", "dump-package",
                    "--package-path", "\(package)",
                    stdout: $0)
                try dump()
                return try $0.readAll()
            }

            json = .init(utf8: utf8[...])
        }
        catch let error
        {
            throw SSGC.ManifestDumpError.init(underlying: error, root: package, leaf: leaf)
        }

        return try json.decode()
    }

    func resolve(package:FilePath.Directory) throws -> [SPM.DependencyPin]
    {
        var arguments:[String] =
        [
            "package",
            "update",
            "--package-path", "\(package)"
        ]
        if  let path:FilePath.Directory = self.swiftCache
        {
            arguments.append("--cache-path")
            arguments.append("\(path)")
        }

        try SystemProcess.init(command: self.swiftCommand, arguments: arguments, echo: true)()

        do
        {
            let resolutions:SPM.DependencyResolutions = try .init(
                parsing: try (package / "Package.resolved").read())
            return resolutions.pins
        }
        catch is FileError
        {
            return []
        }
    }

    func build(package:FilePath.Directory,
        flags:SSGC.PackageBuild.Flags = .init(),
        clean:Bool) throws -> SSGC.PackageBuildDirectory
    {
        let scratch:SSGC.PackageBuildDirectory = .init(configuration: .debug,
            location: package / self.scratch)

        if  clean
        {
            try scratch.location.remove()
        }

        var arguments:[String] =
        [
            "build",
            "--configuration", "\(scratch.configuration)",
            "--package-path", "\(package)",
            "--scratch-path", "\(scratch.location)",
        ]
        if  let path:FilePath.Directory = self.swiftCache
        {
            arguments.append("--cache-path")
            arguments.append("\(path)")
        }
        for flag:String in flags.swift
        {
            arguments.append("-Xswiftc")
            arguments.append(flag)
        }
        for flag:String in flags.cxx
        {
            arguments.append("-Xcxx")
            arguments.append(flag)
        }
        for flag:String in flags.c
        {
            arguments.append("-Xcc")
            arguments.append(flag)
        }

        try SystemProcess.init(command: self.swiftCommand, arguments: arguments, echo: true)()

        return scratch
    }
}
extension SSGC.Toolchain
{
    /// Dumps the symbols for the given targets, using the `output` workspace as the
    /// output directory.
    func dump(module id:Symbol.Module,
        to output:FilePath.Directory,
        options:SymbolDumpOptions = .default,
        include:[FilePath.Directory] = []) throws
    {
        print("Dumping symbols for module '\(id)'")

        var arguments:[String] =
        [
            "symbolgraph-extract",

            "-module-name",                     "\(id)",
            "-target",                          "\(self.triple)",
            "-output-dir",                      "\(output.path)",
        ]

        arguments.append("-minimum-access-level")
        arguments.append("\(options.minimumACL)")

        if  options.emitExtensionBlockSymbols
        {
            arguments.append("-emit-extension-block-symbols")
        }
        if  options.includeInterfaceSymbols
        {
            arguments.append("-include-spi-symbols")
        }
        if  options.skipInheritedDocs
        {
            arguments.append("-skip-inherited-docs")
        }

        #if os(macOS)
        //  On macOS, dumping symbols without specifying the SDK will always fail.
        //  Therefore, we always provide a default SDK.
        let swiftSDK:SSGC.AppleSDK? = self.swiftSDK ?? .macOS
        #else
        let swiftSDK:SSGC.AppleSDK? = self.swiftSDK
        #endif

        if  let swiftSDK:SSGC.AppleSDK
        {
            arguments.append("-sdk")
            arguments.append(swiftSDK.path)
        }

        if  self.pretty
        {
            arguments.append("-pretty-print")
        }
        for include:FilePath.Directory in include
        {
            arguments.append("-I")
            arguments.append("\(include)")
        }

        let environment:SystemProcess.Environment = .inherit
        {
            $0["SWIFT_BACKTRACE"] = "enable=no"
        }
        let extractor:SystemProcess = try .init(command: self.swiftCommand,
            arguments: arguments,
            echo: true,
            with: environment)

        do
        {
            try extractor()
        }
        catch SystemProcessError.exit(139, _)
        {
            print("""
                Failed to dump symbols for module '\(id)' due to SIGSEGV \
                from 'swift symbolgraph-extract'. This is a known bug in the Apple Swift \
                compiler; see https://github.com/apple/swift/issues/68767.
                """)
        }
        catch SystemProcessError.exit(134, _)
        {
            print("""
                Failed to dump symbols for module '\(id)' due to SIGABRT \
                from 'swift symbolgraph-extract'. This is a known bug in the Apple Swift \
                compiler; see https://github.com/swiftlang/swift/issues/75318.
                """)
        }
        catch SystemProcessError.exit(let code, let invocation)
        {
            throw SSGC.PackageBuildError.swift_symbolgraph_extract(code, invocation)
        }
    }
}
