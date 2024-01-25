import PackageGraphs
import PackageMetadata
import SHA1
import SymbolGraphs
import Symbols
import System

extension PackageNode
{
    func pin(to pins:[SPM.DependencyPin]) throws -> [SymbolGraphMetadata.Dependency]
    {
        let pins:SPM.DependencyPins = try .init(indexing: pins)
        return try self.dependencies.map
        {
            let pin:SPM.DependencyPin = try pins($0.id)
            return .init(package: .init(scope: pin.location.owner, name: $0.id),
                requirement: ($0 as? SPM.Manifest.Dependency)?.requirement?.stable,
                revision: pin.revision,
                version: pin.version)
        }
    }
}
