import MongoDB
import Symbols
import UnidocAPI
import UnidocDB

extension Unidoc
{
    struct EditionMetadataSymbolicQuery
    {
        let package:Symbol.Package
        let version:VersionPredicate

        init(package:Symbol.Package, version:VersionPredicate)
        {
            self.package = package
            self.version = version
        }
    }
}
extension Unidoc.EditionMetadataSymbolicQuery:Unidoc.AliasingQuery
{
    typealias Iteration = Mongo.Single<Unidoc.EditionOutput>
    typealias CollectionOrigin = Unidoc.DB.PackageAliases
    typealias CollectionTarget = Unidoc.DB.Packages

    var symbol:Symbol.Package { self.package }

    static
    var target:Mongo.AnyKeyPath { Unidoc.EditionOutput[.package] }

    func extend(pipeline:inout Mongo.PipelineEncoder)
    {
        pipeline.loadEdition(matching: self.version,
            from: Unidoc.EditionOutput[.package],
            into: Unidoc.EditionOutput[.edition])
    }
}
