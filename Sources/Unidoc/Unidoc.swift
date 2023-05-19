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

        print("Note: using toolchain version \(toolchain.version?.description ?? "<unstable>")")
        print("Note: using toolchain triple '\(toolchain.triple)'")

        let workspace:Workspace = try await .create(at: ".unidoc")
        let checkout:RepositoryCheckout = try await workspace.checkout(
            url: "https://github.com/apple/swift-syntax.git",
            at: "508.0.0")

        let artifacts:DocumentationArtifacts = try await toolchain.generateArtifactsForPackage(
            in: checkout)
        let archive:DocumentationArchive = try await artifacts.build()

        let bson:BSON.Document = .init(encoding: archive)

        print("Built documentation (\(bson.bytes.count >> 10) KB)")

        let output:FilePath = workspace.path /
            "\(checkout.pin.id)@\(checkout.pin.revision).bsda"

        try output.overwrite(with: bson.bytes)

        print("Documentation saved to: \(output)")
    }
}
