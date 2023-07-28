import BSONDecoding
import SymbolGraphBuilder
import SymbolGraphs
import SymbolGraphTesting
import System
import Testing

@main
enum Main:AsyncTests
{
    static
    func run(tests:Tests) async
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
            let documentation:Documentation = (await tests.do
            {
                try await toolchain.generateDocs(for: try await .swift(
                        in: workspace,
                        clean: true),
                    pretty: true)
            })
        {
            documentation.roundtrip(for: tests, in: workspace.path)
        }

        if  let tests:TestGroup = tests / "swift-atomics",
            let documentation:Documentation = (await tests.do
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
            documentation.roundtrip(for: tests, in: workspace.path)
        }

        if  let tests:TestGroup = tests / "swift-nio",
            let documentation:Documentation = (await tests.do
            {
                try await toolchain.generateDocs(for: try await .remote(
                        package: "swift-nio",
                        from: "https://github.com/apple/swift-nio.git",
                        at: "2.57.0",
                        in: workspace,
                        clean: true),
                    pretty: true)
            })
        {
            //  the swift-docc-plugin dependency should have been linted.
            tests.expect(documentation.metadata.dependencies.map(\.package) **?
            [
                "swift-collections",
                "swift-atomics",
            ])

            documentation.roundtrip(for: tests, in: workspace.path)

        }

        //  SwiftNIO has lots of dependencies. If we can handle SwiftNIO,
        //  we can handle anything!
        if  let tests:TestGroup = tests / "swift-nio-ssl",
            let documentation:Documentation = (await tests.do
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
            tests.expect(documentation.metadata.dependencies.map(\.package) **?
            [
                "swift-collections",
                "swift-atomics",
                "swift-nio",
            ])

            documentation.roundtrip(for: tests, in: workspace.path)
        }

        //  SwiftSyntax is a morbidly obese package. If we can handle SwiftSyntax,
        //  we can handle anything!
        if  let tests:TestGroup = tests / "swift-syntax",
            let documentation:Documentation = (await tests.do
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
            tests.expect(documentation.metadata.dependencies.map(\.package) **? [])

            documentation.roundtrip(for: tests, in: workspace.path)
        }
    }
}
