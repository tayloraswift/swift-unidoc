import ModuleGraphs
import PackageGraphs
import SHA1
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
            let sha1:SHA1

            switch pin.revision
            {
            case .sha1(let hash):   sha1 = hash
            }

            return .init(package: $0.id,
                requirement: $0.requirement?.stable,
                revision: sha1,
                version: pin.version)
        }
    }
}
