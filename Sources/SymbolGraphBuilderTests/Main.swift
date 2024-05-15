import BSON
import SymbolGraphBuilder
import SymbolGraphs
import SymbolGraphTesting
import System
import Testing_

@main
enum Main:TestMain, TestBattery
{
    static
    func run(tests:TestGroup) async
    {
        if  let tests:TestGroup = tests / "SplashParsing"
        {
            if  let tests:TestGroup = tests / "LinuxNightly",
                let swift:SSGC.Toolchain = tests.expect(value: try? .init(parsing: """
                    Swift version 5.8-dev (LLVM 07d14852a049e40, Swift 613b3223d9ec5f6)
                    Target: x86_64-unknown-linux-gnu

                    """))
            {
                tests.expect(swift.version ==? .init(version: .v(5, 8, 0),
                    nightly: .DEVELOPMENT_SNAPSHOT))
                tests.expect(swift.triple ==? .init("x86_64", "unknown", "linux", "gnu"))
            }
            if  let tests:TestGroup = tests / "Linux",
                let swift:SSGC.Toolchain = tests.expect(value: try? .init(parsing: """
                    Swift version 5.10 (swift-5.10-RELEASE)
                    Target: x86_64-unknown-linux-gnu

                    """))
            {
                tests.expect(swift.version ==? .init(version: .v(5, 10, 0), nightly: nil))
                tests.expect(swift.triple ==? .init("x86_64", "unknown", "linux", "gnu"))
            }
            if  let tests:TestGroup = tests / "Xcode",
                let swift:SSGC.Toolchain = tests.expect(value: try? .init(parsing: """
                    swift-driver version: 1.90.11.1 \
                    Apple Swift version 5.10 (swiftlang-5.10.0.13 clang-1500.3.9.4)
                    Target: arm64-apple-macosx14.0

                    """))
            {
                tests.expect(swift.version ==? .init(version: .v(5, 10, 0), nightly: nil))
                tests.expect(swift.triple ==? .init("arm64", "apple", "macosx14.0", nil))
            }
        }

        guard
        let workspace:SSGC.Workspace =
            (tests ! "workspace").do({ try .create(at: ".testing") }),
        let toolchain:SSGC.Toolchain =
            (tests ! "toolchain").do({ try .detect(pretty: true) })
        else
        {
            return
        }

        if  let tests:TestGroup = tests / "standard-library",
            let docs:SymbolGraphObject<Void> = (tests.do
            {
                try workspace.build(special: .swift, with: toolchain)
            })
        {
            docs.roundtrip(for: tests, in: workspace.artifacts)
        }

        if  let tests:TestGroup = tests / "swift-atomics",
            let docs:SymbolGraphObject<Void> = (tests.do
            {
                try workspace.build(package: try .remote(
                        package: "swift-atomics",
                        from: "https://github.com/apple/swift-atomics.git",
                        at: "1.1.0",
                        in: workspace),
                    with: toolchain)
            })
        {
            docs.roundtrip(for: tests, in: workspace.artifacts)
        }

        //  https://github.com/tayloraswift/swift-unidoc/issues/211
        #if !os(macOS)
        if  let tests:TestGroup = tests / "swift-nio",
            let docs:SymbolGraphObject<Void> = (tests.do
            {
                try workspace.build(package: try .remote(
                        package: "swift-nio",
                        from: "https://github.com/apple/swift-nio.git",
                        at: "2.65.0",
                        in: workspace),
                    with: toolchain)
            })
        {
            //  the swift-docc-plugin dependency should have been linted.
            tests.expect(docs.metadata.dependencies.map(\.package.name) **?
            [
                "swift-atomics",
                "swift-collections",
                //  swift-nio grew a dependency on swift-system in 2.63.0
                "swift-system",
            ])

            docs.roundtrip(for: tests, in: workspace.artifacts)
        }
        #endif

        //  SwiftNIO has lots of dependencies. If we can handle SwiftNIO,
        //  we can handle anything!
        if  let tests:TestGroup = tests / "swift-nio-ssl",
            let docs:SymbolGraphObject<Void> = (tests.do
            {
                try workspace.build(package: try .remote(
                        package: "swift-nio-ssl",
                        from: "https://github.com/apple/swift-nio-ssl.git",
                        at: "2.24.0",
                        in: workspace),
                    with: toolchain)
            })
        {
            tests.expect(docs.metadata.dependencies.map(\.package.name) **?
            [
                "swift-collections",
                "swift-atomics",
                "swift-nio",
            ])

            docs.roundtrip(for: tests, in: workspace.artifacts)
        }

        //  The swift-async-dns-resolver repo includes a git submodule, so we should be able
        //  to handle that.
        if  let tests:TestGroup = tests / "swift-async-dns-resolver",
            let docs:SymbolGraphObject<Void> = (tests.do
            {
                try workspace.build(package: try .remote(
                        package: "swift-async-dns-resolver",
                        from: "https://github.com/apple/swift-async-dns-resolver.git",
                        at: "0.1.2",
                        in: workspace),
                    with: toolchain)
            })
        {
            tests.expect(docs.metadata.dependencies.map(\.package.name) **?
            [
                "swift-collections",
                "swift-atomics",
                "swift-nio",
            ])

            docs.roundtrip(for: tests, in: workspace.artifacts)
        }

        //  SwiftSyntax is a morbidly obese package. If we can handle SwiftSyntax,
        //  we can handle anything!
        if  let tests:TestGroup = tests / "swift-syntax",
            let docs:SymbolGraphObject<Void> = (tests.do
            {
                try workspace.build(package: try .remote(
                        package: "swift-syntax",
                        from: "https://github.com/apple/swift-syntax.git",
                        at: "508.0.0",
                        in: workspace),
                    with: toolchain)
            })
        {
            //  the swift-argument-parser dependency should have been linted.
            tests.expect(docs.metadata.dependencies.map(\.package.name) **? [])

            docs.roundtrip(for: tests, in: workspace.artifacts)
        }

        //  IndexstoreDB links the LLVM Blocks runtime, so this tests that we handle that.
        //  Since it involves specifying the location of the Swift runtime, we can only expect
        //  this to work within a particular Docker container.
        #if false
        if  let tests:TestGroup = tests / "indexstore-db",
            let docs:SymbolGraphObject<Void> = (tests.do
            {
                try workspace.build(package: try .remote(
                        package: "indexstore-db",
                        from: "https://github.com/apple/indexstore-db.git",
                        at: "swift-5.10-RELEASE",
                        in: workspace,
                        flags: .init(cxx: ["-I/usr/lib/swift", "-I/usr/lib/swift/Block"])),
                    with: toolchain)
            })
        {
            tests.expect(docs.metadata.dependencies.map(\.package.name) **? [])

            docs.roundtrip(for: tests, in: workspace.artifacts)
        }
        #endif
    }
}
