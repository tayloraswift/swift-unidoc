#if canImport(IndexStoreDB)

import class IndexStoreDB.IndexStoreLibrary

#endif

import JSON
import PackageMetadata
import SemanticVersions
import SymbolGraphs
import Symbols
import System_

extension SSGC
{
    @frozen public
    struct Toolchain
    {
        private
        let appleSDK:AppleSDK?
        public
        let splash:Splash
        private
        let paths:Paths

        private
        let recoverFromAppleBugs:Bool
        private
        let pretty:Bool

        public
        init(appleSDK:AppleSDK?,
            splash:Splash,
            paths:Paths,
            recoverFromAppleBugs:Bool,
            pretty:Bool)
        {
            self.appleSDK = appleSDK
            self.splash = splash
            self.paths = paths
            self.recoverFromAppleBugs = recoverFromAppleBugs
            self.pretty = pretty
        }
    }
}
extension SSGC.Toolchain
{
    public static
    func detect(appleSDK:SSGC.AppleSDK? = nil,
        paths:Paths = .init(swiftPM: nil, usr: nil),
        recoverFromAppleBugs:Bool = true,
        pretty:Bool = false) throws -> Self
    {
        let (readable, writable):(FileDescriptor, FileDescriptor) = try FileDescriptor.pipe()

        defer
        {
            try? writable.close()
            try? readable.close()
        }

        try SystemProcess.init(command: paths.swiftCommand, "--version", stdout: writable)()
        return .init(appleSDK: appleSDK,
            splash: try .init(parsing: try readable.read(buffering: 1024)),
            paths: paths,
            recoverFromAppleBugs: recoverFromAppleBugs,
            pretty: pretty)
    }
}
extension SSGC.Toolchain
{
    #if canImport(IndexStoreDB)

    func libIndexStore() throws -> IndexStoreLibrary
    {
        try .init(dylibPath: "\(self.paths.libIndexStore)")
    }

    #endif

    func platform() throws -> SymbolGraphMetadata.Platform
    {
        if      self.splash.triple.os.starts(with: "linux")
        {
            return .linux
        }
        else if self.splash.triple.os.starts(with: "ios")
        {
            return .iOS
        }
        else if self.splash.triple.os.starts(with: "macos")
        {
            return .macOS
        }
        else if self.splash.triple.os.starts(with: "tvos")
        {
            return .tvOS
        }
        else if self.splash.triple.os.starts(with: "watchos")
        {
            return .watchOS
        }
        else if self.splash.triple.os.starts(with: "windows")
        {
            return .windows
        }
        else
        {
            throw SSGC.ToolchainError.unsupportedTriple(self.splash.triple)
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
                let dump:SystemProcess = try .init(command: self.paths.swiftCommand,
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
        if  let path:FilePath.Directory = self.paths.swiftPM
        {
            arguments.append("--cache-path")
            arguments.append("\(path)")
        }

        try SystemProcess.init(command: self.paths.swiftCommand,
            arguments: arguments,
            echo: true)()

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
        using scratch:SSGC.PackageBuildDirectory,
        flags:SSGC.PackageBuild.Flags = .init()) throws
    {
        var arguments:[String] =
        [
            "build",
            "--configuration", "\(scratch.configuration)",
            "--package-path", "\(package)",
            "--scratch-path", "\(scratch.location)",
        ]
        if  let path:FilePath.Directory = self.paths.swiftPM
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

        try SystemProcess.init(command: self.paths.swiftCommand,
            arguments: arguments,
            echo: true)()
    }
}
extension SSGC.Toolchain
{
    /// Dumps the symbols for the standard library. Due to upstream bugs in the Swift compiler,
    /// this methods disables extension block symbols by default.
    func dump(
        standardLibrary:SSGC.StandardLibrary,
        options:SymbolDumpOptions = .init(allowedReexportedModules: [
                "_Concurrency",
                "_StringProcessing",
                "FoundationEssentials",
                "FoundationInternationalization",
            ],
            emitExtensionBlockSymbols: false),
        cache:FilePath.Directory) throws -> FilePath.Directory
    {
        let cached:FilePath.Directory = cache / "swift@\(self.splash.swift.version)"

        if !cached.exists()
        {
            let temporary:FilePath.Directory = cache / "swift"
            try temporary.create(clean: true)

            for module:SymbolGraph.Module in standardLibrary.modules
            {
                try self.dump(module: module.id, to: temporary, options: options)
            }

            try temporary.move(replacing: cached)
        }

        return cached
    }

    /// Dumps the symbols for the given targets, using the `output` workspace as the
    /// output directory.
    func dump(module id:Symbol.Module,
        to output:FilePath.Directory,
        options:SymbolDumpOptions,
        include:[FilePath.Directory] = []) throws
    {
        print("Dumping symbols for module '\(id)'")

        var arguments:[String] =
        [
            "symbolgraph-extract",

            "-module-name",                     "\(id)",
            "-target",                          "\(self.splash.triple)",
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
        if  self.splash.swift.version >= .v(6, 0, 0),
            //  Temporary hack until we have the right stdlib definitions for macOS
            self.splash.triple.os.starts(with: "linux"),
            !options.allowedReexportedModules.isEmpty
        {
            let whitelist:String = options.allowedReexportedModules.lazy.map { "\($0)" }.joined(
                separator: ",")

            arguments.append("""
                -experimental-allowed-reexported-modules=\(whitelist)
                """)
        }

        #if os(macOS)
        //  On macOS, dumping symbols without specifying the SDK will always fail.
        //  Therefore, we always provide a default SDK.
        let appleSDK:SSGC.AppleSDK? = self.appleSDK ?? .macOS
        #else
        let appleSDK:SSGC.AppleSDK? = self.appleSDK
        #endif

        if  let appleSDK:SSGC.AppleSDK
        {
            arguments.append("-sdk")
            arguments.append(appleSDK.path)
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
        let extractor:SystemProcess = try .init(command: self.paths.swiftCommand,
            arguments: arguments,
            echo: true,
            with: environment)

        do
        {
            try extractor()
        }
        catch SystemProcessError.exit(let code, let invocation)
        {
            guard self.recoverFromAppleBugs
            else
            {
                throw SSGC.PackageBuildError.swift_symbolgraph_extract(code, invocation)
            }

            switch code
            {
            case 139:
                print("""
                    Failed to dump symbols for module '\(id)' due to SIGSEGV \
                    from 'swift symbolgraph-extract'. \
                    This is a known bug in the Apple Swift compiler; see \
                    https://github.com/apple/swift/issues/68767.
                    """)
            case 134:
                print("""
                    Failed to dump symbols for module '\(id)' due to SIGABRT \
                    from 'swift symbolgraph-extract'. \
                    This is a known bug in the Apple Swift compiler; see \
                        https://github.com/swiftlang/swift/issues/75318.
                    """)

            case let code:
                print("""
                    Failed to dump symbols for module '\(id)' due to exit code \(code) \
                    from 'swift symbolgraph-extract'. \
                    If the output above indicates 'swift symbolgraph-extract' exited \
                    gracefully, this is most likely because the module.modulemap file declares \
                    a different module name than we detected from the package manifest.
                    """)
            }
        }
    }
}
