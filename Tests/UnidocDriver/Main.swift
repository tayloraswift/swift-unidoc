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
            try await .create(at: ".unidoc-driver-testing")
        }
        let toolchain:Toolchain? = await (tests ! "toolchain").do
        {
            try await .detect()
        }

        if  let workspace:Workspace,
            let toolchain:Toolchain,
            let tests:TestGroup = tests / "standard-library",
            let artifacts:DocumentationArtifacts = (await tests.do
            {
                try await toolchain.generateArtifactsForStandardLibrary(
                    in: try await workspace.create("swift.doc",
                        clean: true),
                    pretty: true)
            })
        {
            await TestRoundtripping(tests,
                artifacts: artifacts,
                output: workspace.path / "swift@\(toolchain.version.name).bsda")
        }

        if  let workspace:Workspace,
            let toolchain:Toolchain,
            let tests:TestGroup = tests / "swift-syntax",
            let artifacts:DocumentationArtifacts = (await tests.do
            {
                try await toolchain.generateArtifactsForPackage(
                    in: try await workspace.checkout(
                        url: "https://github.com/apple/swift-syntax.git",
                        at: "508.0.0",
                        clean: true),
                    pretty: true)
            })
        {
            await TestRoundtripping(tests,
                artifacts: artifacts,
                output: workspace.path / "swift-syntax.bsda")
        }
    }
}
