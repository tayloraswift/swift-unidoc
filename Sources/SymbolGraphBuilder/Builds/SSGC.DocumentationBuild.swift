import SymbolGraphs
import System

extension SSGC
{
    protocol DocumentationBuild
    {
        associatedtype Logs:DocumentationLogger

        mutating
        func compile(
            with swift:Toolchain,
            logs:inout Logs) async throws -> (SymbolGraphMetadata, SSGC.PackageSources)

        var artifacts:ArtifactsDirectory { get }
    }
}
