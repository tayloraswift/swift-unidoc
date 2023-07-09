import ModuleGraphs
import PackageGraphs
import SymbolGraphs
import System

extension PackageNode
{
    func pinnedDependencies(
        using pins:[Repository.Pin]) throws -> [SymbolGraphMetadata.Dependency]
    {
        let pins:Repository.Pins = try .init(indexing: pins)
        return try self.dependencies.map
        {
            let pin:Repository.Pin = try pins($0.id)
            return .init(package: $0.id,
                requirement: $0.requirement?.stable,
                revision: pin.revision,
                version: pin.version)
        }
    }
}
