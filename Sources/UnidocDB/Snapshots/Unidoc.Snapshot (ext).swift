import MongoQL
import Symbols
import UnidocRecords

extension Unidoc.Snapshot:MongoMasterCodingModel
{
}
extension Unidoc.Snapshot
{
    /// Exonyms are the names the package being linked uses to refer to its dependencies.
    /// Exonyms should never contain a scope qualifier.
    func exonyms() -> [Unidoc.Edition: Symbol.Package]
    {
        var exonyms:[Unidoc.Edition: Symbol.Package] = .init(minimumCapacity: self.pins.count)

        for case (let pin?, let dependency) in zip(self.pins, self.metadata.dependencies)
        {
            exonyms[pin] = dependency.package.name
        }

        return exonyms
    }
}
