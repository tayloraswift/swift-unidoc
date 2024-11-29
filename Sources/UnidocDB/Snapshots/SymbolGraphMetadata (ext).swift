import MongoQL
import SymbolGraphs
import Symbols

extension SymbolGraphMetadata:Mongo.MasterCodingModel
{
}
extension SymbolGraphMetadata
{
    /// Exonyms are the names the package being linked uses to refer to its dependencies.
    /// Exonyms should never contain a scope qualifier.
    func exonyms(pins:[Unidoc.EditionMetadata?]) -> [Unidoc.Edition: Symbol.Package]
    {
        var exonyms:[Unidoc.Edition: Symbol.Package] = .init(minimumCapacity: pins.count)

        for case (let pin?, let dependency) in zip(pins, self.dependencies)
        {
            exonyms[pin.id] = dependency.package.name
        }

        return exonyms
    }
}
