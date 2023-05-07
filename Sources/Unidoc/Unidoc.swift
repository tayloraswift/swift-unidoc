import PackageMetadata
import System

@main
enum Unidoc
{
    public static
    func main() async throws
    {
        let workspace:FilePath = ".unidoc"

        try await SystemProcess.init(command: "mkdir", arguments: ["-p", workspace.string])()

        let context:RepositoryContext = try await .setup(
            cloning: "https://github.com/apple/swift-syntax",
            into: "swift-syntax",
            in: workspace)

        try await context.build()

        let manifest:PackageManifest = try await context.loadManifest()
        let resolutions:PackageResolutions = try context.loadResolutions()

        print(manifest)
        print(resolutions)
    }
}
