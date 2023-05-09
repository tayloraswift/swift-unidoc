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

        let _:PackageResolutions = try checkout.loadPackageResolved()

        let manifest:PackageManifest = try await checkout.dumpManifest()

        print("name:", manifest.name)
        print("root:", manifest.root)

        let targets:[PackageManifest.Target] = try manifest.libraries()
        try await checkout.dumpSymbols(targets.map(\.id.mangled))
    }
}
