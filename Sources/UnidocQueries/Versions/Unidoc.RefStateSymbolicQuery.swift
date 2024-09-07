import MongoDB
import Symbols
import UnidocAPI
import UnidocDB

extension Unidoc
{
    struct RefStateSymbolicQuery
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
extension Unidoc.RefStateSymbolicQuery:Mongo.PipelineQuery
{
    typealias Iteration = Mongo.Single<Unidoc.RefState>
}
extension Unidoc.RefStateSymbolicQuery:Unidoc.AliasingQuery
{
    typealias CollectionOrigin = Unidoc.DB.PackageAliases
    typealias CollectionTarget = Unidoc.DB.Packages

    var symbol:Symbol.Package { self.package }

    static
    var target:Mongo.AnyKeyPath { Unidoc.RefState[.package] }

    func extend(pipeline:inout Mongo.PipelineEncoder)
    {
        pipeline.loadTags(matching: self.version,
            from: Unidoc.RefState[.package],
            into: Unidoc.RefState[.version])

        //  Unbox single-element array.
        pipeline[stage: .unwind] = Unidoc.RefState[.version]

        pipeline.loadUser(
            owning: Unidoc.RefState[.package],
            as: Unidoc.RefState[.owner])

        pipeline[stage: .lookup]
        {
            $0[.from] = Unidoc.DB.PackageBuilds.name
            $0[.localField] = Unidoc.RefState[.package] / Unidoc.PackageMetadata[.id]
            $0[.foreignField] = Unidoc.BuildMetadata[.id]
            $0[.as] = Unidoc.RefState[.build]
        }

        pipeline[stage: .set, using: Unidoc.RefState.CodingKey.self]
        {
            $0[.build] { $0[.first] = Unidoc.RefState[.build] }
        }
    }
}
