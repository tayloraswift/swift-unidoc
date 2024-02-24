import SymbolGraphs
import System

protocol DocumentationBuild
{
    mutating
    func compile(with swift:Toolchain) async throws -> (SymbolGraphMetadata, SPM.PackageSources)

    var artifacts:ArtifactsDirectory { get }
}
