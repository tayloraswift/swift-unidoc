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
            let packageScope:Symbol.PackageScope?

            switch pin.location
            {
            case .local:
                packageScope = nil

            case .remote(let url):
                guard
                let j:String.Index = url.lastIndex(of: "/"),
                let i:String.Index = url[..<j].lastIndex(of: "/"),
                url[..<i] == "https://github.com"
                else
                {
                    packageScope = nil
                    break
                }

                let start:String.Index = url.index(after: i)
                packageScope = .init(url[start ..< j])
            }

            return .init(package: $0.id,
                packageScope: packageScope,
                requirement: ($0 as? SPM.Manifest.Dependency)?.requirement?.stable,
                revision: pin.revision,
                version: pin.version)
        }
    }
}
