import PackageMetadata
import Repositories
import System

@main
enum Unidoc
{
    public static
    func main() async throws
    {
        let workspace:Workspace = try await .create(at: ".unidoc")

        let checkout:Workspace.Checkout = try await workspace.checkout(
            url: "https://github.com/apple/swift-syntax.git",
            at: "508.0.0")

        try await checkout.build()

        let _:PackageResolutions = try checkout.loadResolutions()
        let manifest:PackageManifest = try await checkout.loadManifest()

        print("name:", manifest.name)
        print("root:", manifest.root)
        print("products:", manifest.products)
    }
}
