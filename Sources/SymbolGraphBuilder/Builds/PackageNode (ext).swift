import PackageGraphs
import PackageMetadata
import SHA1
import SymbolGraphs
import System

extension PackageNode
{
    func pinnedDependencies(
        using pins:[PackageManifest.DependencyPin]) throws -> [SymbolGraphMetadata.Dependency]
    {
        let pins:PackageManifest.DependencyPins = try .init(indexing: pins)
        return try self.dependencies.map
        {
            let pin:PackageManifest.DependencyPin = try pins($0.id)
            return .init(package: $0.id,
                requirement: ($0 as? PackageManifest.Dependency)?.requirement?.stable,
                revision: pin.revision,
                version: pin.version)
        }
    }
}
