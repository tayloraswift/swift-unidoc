import BSONEncoding
import SymbolGraphs
import System
import UnidocDriver

@main
enum Unidoc
{
    public static
    func main() async throws
    {
        let toolchain:Toolchain = try await .detect()

        print("Note: using toolchain version \(toolchain.version)")
        print("Note: using toolchain triple '\(toolchain.triple)'")

        let workspace:Workspace = try await .create(at: ".unidoc")

        let documentation:DocumentationArchive
        let output:FilePath

        switch CommandLine.arguments.dropFirst().first
        {
        case "-s"?, "--stdlib"?:
            let directory:Workspace = try await workspace.create("swift.doc",
                clean: true)

            documentation = try await toolchain.generateDocsForStandardLibrary(
                in: directory)
            output = workspace.path / "swift@\(toolchain.version.canonical).bsda"

        case nil:
            let checkout:RepositoryCheckout = try await workspace.checkout(
                url: "https://github.com/apple/swift-syntax.git",
                at: "508.0.0",
                clean: true)

            documentation = try await toolchain.generateDocsForPackage(
                in: checkout)
            output = workspace.path / "\(checkout.pin.id)@\(checkout.pin.revision).bsda"

        case let command?:
            fatalError("unrecognized command '\(command)'")
        }

        let bson:BSON.Document = .init(encoding: documentation)

        print("Built documentation (\(bson.bytes.count >> 10) KB)")

        try output.overwrite(with: bson.bytes)

        print("Documentation saved to: \(output)")
    }
}
