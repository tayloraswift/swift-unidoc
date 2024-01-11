import BSON
import SymbolGraphBuilder
import SymbolGraphs
import SymbolGraphTesting
import System
import Testing

@main
enum Main:TestMain, TestBattery
{
    static
    func run(tests:TestGroup) async
    {
        guard   let workspace:Workspace =
                    await (tests ! "workspace").do({ try await .create(at: ".testing") }),
                let toolchain:Toolchain =
                    await (tests ! "toolchain").do({ try await .detect() })
        else
        {
            return
        }

        if  let tests:TestGroup = tests / "standard-library",
            let docs:SymbolGraphArchive = (await tests.do
            {
                try await toolchain.generateDocs(for: try await .swift(
                        in: workspace,
                        clean: true),
                    pretty: true)
            })
        {
            docs.roundtrip(for: tests, in: workspace.path)
        }

        if  let tests:TestGroup = tests / "swift-atomics",
            let docs:SymbolGraphArchive = (await tests.do
            {
                try await toolchain.generateDocs(for: try await .remote(
                        package: "swift-atomics",
                        from: "https://github.com/apple/swift-atomics.git",
                        at: "1.1.0",
                        in: workspace,
                        clean: true),
                    pretty: true)
            })
        {
            docs.roundtrip(for: tests, in: workspace.path)
        }

        if  let tests:TestGroup = tests / "swift-nio",
            let docs:SymbolGraphArchive = (await tests.do
            {
                try await toolchain.generateDocs(for: try await .remote(
                        package: "swift-nio",
                        from: "https://github.com/apple/swift-nio.git",
                        at: "2.58.0",
                        in: workspace,
                        clean: true),
                    pretty: true)
            })
        {
            //  the swift-docc-plugin dependency should have been linted.
            tests.expect(docs.metadata.dependencies.map(\.package) **?
            [
                "swift-collections",
                "swift-atomics",
            ])

            docs.roundtrip(for: tests, in: workspace.path)

        }

        //  SwiftNIO has lots of dependencies. If we can handle SwiftNIO,
        //  we can handle anything!
        if  let tests:TestGroup = tests / "swift-nio-ssl",
            let docs:SymbolGraphArchive = (await tests.do
            {
                try await toolchain.generateDocs(for: try await .remote(
                        package: "swift-nio-ssl",
                        from: "https://github.com/apple/swift-nio-ssl.git",
                        at: "2.24.0",
                        in: workspace,
                        clean: true),
                    pretty: true)
            })
        {
            tests.expect(docs.metadata.dependencies.map(\.package) **?
            [
                "swift-collections",
                "swift-atomics",
                "swift-nio",
            ])

            docs.roundtrip(for: tests, in: workspace.path)
        }

        //  The swift-async-dns-resolver repo includes a git submodule, so we should be able
        //  to handle that.
        if  let tests:TestGroup = tests / "swift-async-dns-resolver",
            let docs:SymbolGraphArchive = (await tests.do
            {
                try await toolchain.generateDocs(for: try await .remote(
                        package: "swift-async-dns-resolver",
                        from: "https://github.com/apple/swift-async-dns-resolver.git",
                        at: "0.1.2",
                        in: workspace,
                        clean: true),
                    pretty: true)
            })
        {
            tests.expect(docs.metadata.dependencies.map(\.package) **?
            [
                "swift-collections",
                "swift-atomics",
                "swift-nio",
            ])

            docs.roundtrip(for: tests, in: workspace.path)
        }

        //  SwiftSyntax is a morbidly obese package. If we can handle SwiftSyntax,
        //  we can handle anything!
        if  let tests:TestGroup = tests / "swift-syntax",
            let docs:SymbolGraphArchive = (await tests.do
            {
                try await toolchain.generateDocs(for: try await .remote(
                        package: "swift-syntax",
                        from: "https://github.com/apple/swift-syntax.git",
                        at: "508.0.0",
                        in: workspace,
                        clean: true),
                    pretty: true)
            })
        {
            //  the swift-argument-parser dependency should have been linted.
            tests.expect(docs.metadata.dependencies.map(\.package) **? [])

            docs.roundtrip(for: tests, in: workspace.path)
        }
    }
}
