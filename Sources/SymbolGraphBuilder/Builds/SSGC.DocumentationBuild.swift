import SymbolGraphs
import System

extension SSGC
{
    protocol DocumentationBuild
    {
        mutating
        func compile(
            with swift:Toolchain) async throws -> (SymbolGraphMetadata, SSGC.PackageSources)

        var artifacts:ArtifactsDirectory { get }
    }
}
