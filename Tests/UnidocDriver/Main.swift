import BSONDecoding
import SymbolGraphs
import System
import Testing
import UnidocDriver

@main
enum Main:AsyncTests
{
    static
    func run(tests:Tests) async
    {
        #if DEBUG
        if ({ true }())
        {
            print("""
                Warning: skipping unidoc driver integration tests because we are in debug mode!
                """)
            return
        }
        #endif

        let workspace:Workspace? = await (tests ! "setup").do
        {
            try await .create(at: ".unidoc-testing")
        }
        let toolchain:Toolchain? = await (tests ! "toolchain").do
        {
            try await .detect()
        }

        if  let workspace:Workspace,
            let toolchain:Toolchain,
            let tests:TestGroup = tests / "standard-library",
            let documentation:DocumentationArchive = (await tests.do
            {
                try await toolchain.generateDocsForStandardLibrary(
                    in: try await workspace.create("swift@\(toolchain.version.canonical)",
                        clean: true),
                    pretty: true)
            })
        {
            TestRoundtripping(tests,
                documentation: documentation,
                output: workspace.path / "swift.bsdo")
        }

        if  let workspace:Workspace,
            let toolchain:Toolchain,
            let tests:TestGroup = tests / "swift-atomics",
            let documentation:DocumentationArchive = (await tests.do
            {
                try await toolchain.generateDocs(
                    cloning: "https://github.com/apple/swift-atomics.git",
                    at: "1.1.0",
                    in: workspace,
                    pretty: true,
                    clean: true)
            })
        {
            TestRoundtripping(tests,
                documentation: documentation,
                output: workspace.path / "swift-atomics.bsdo")
        }

        if  let workspace:Workspace,
            let toolchain:Toolchain,
            let tests:TestGroup = tests / "swift-nio",
            let documentation:DocumentationArchive = (await tests.do
            {
                try await toolchain.generateDocs(
                    cloning: "https://github.com/apple/swift-nio.git",
                    at: "2.53.0",
                    in: workspace,
                    pretty: true,
                    clean: true)
            })
        {
            //  the swift-docc-plugin dependency should have been linted.
            tests.expect(documentation.metadata.dependencies.map(\.package) **?
            [
                "swift-collections",
                "swift-atomics",
            ])

            TestRoundtripping(tests,
                documentation: documentation,
                output: workspace.path / "swift-nio.bsdo")

        }

        //  SwiftNIO has lots of dependencies. If we can handle SwiftNIO,
        //  we can handle anything!
        if  let workspace:Workspace,
            let toolchain:Toolchain,
            let tests:TestGroup = tests / "swift-nio-ssl",
            let documentation:DocumentationArchive = (await tests.do
            {
                try await toolchain.generateDocs(
                    cloning: "https://github.com/apple/swift-nio-ssl.git",
                    at: "2.24.0",
                    in: workspace,
                    pretty: true,
                    clean: true)
            })
        {
            tests.expect(documentation.metadata.dependencies.map(\.package) **?
            [
                "swift-collections",
                "swift-atomics",
                "swift-nio",
            ])

            TestRoundtripping(tests,
                documentation: documentation,
                output: workspace.path / "swift-nio-ssl.bsdo")
        }

        //  SwiftSyntax is a morbidly obese package. If we can handle SwiftSyntax,
        //  we can handle anything!
        if  let workspace:Workspace,
            let toolchain:Toolchain,
            let tests:TestGroup = tests / "swift-syntax",
            let documentation:DocumentationArchive = (await tests.do
            {
                try await toolchain.generateDocs(
                    cloning: "https://github.com/apple/swift-syntax.git",
                    at: "508.0.0",
                    in: workspace,
                    pretty: true,
                    clean: true)
            })
        {
            //  the swift-argument-parser dependency should have been linted.
            tests.expect(documentation.metadata.dependencies.map(\.package) **? [])

            TestRoundtripping(tests,
                documentation: documentation,
                output: workspace.path / "swift-syntax.bsdo")
        }
    }
}
