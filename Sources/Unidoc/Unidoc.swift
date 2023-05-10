import BSONEncoding
import SymbolGraphDriver
import SymbolGraphs
import System

@main
enum Unidoc
{
    public static
    func main() async throws
    {
        let workspace:Driver.Workspace = try await .create(at: ".unidoc")
        let checkout:Driver.Checkout = try await workspace.checkout(
            url: "https://github.com/apple/swift-syntax.git",
            at: "508.0.0")

        let artifacts:Driver.Artifacts = try await checkout.buildPackage()
        let graph:SymbolGraph = try await artifacts.buildSymbolGraph()

        let bson:BSON.Document = .init(encoding: graph)

        print("Linked symbolgraph (\(bson.bytes.count >> 10) KB)")

        let output:FilePath = workspace.path /
            "\(checkout.pin.id)@\(checkout.pin.revision).bssg"

        try await output.overwrite(with: bson.bytes)

        print("Symbolgraph saved to: \(output)")
    }
}
