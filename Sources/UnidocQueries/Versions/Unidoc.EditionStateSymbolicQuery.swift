import MongoDB
import Symbols
import UnidocAPI
import UnidocDB

extension Unidoc
{
    struct EditionStateSymbolicQuery
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
extension Unidoc.EditionStateSymbolicQuery:Mongo.PipelineQuery
{
    typealias Iteration = Mongo.Single<Unidoc.EditionState>
}
extension Unidoc.EditionStateSymbolicQuery:Unidoc.AliasingQuery
{
    typealias CollectionOrigin = Unidoc.DB.PackageAliases
    typealias CollectionTarget = Unidoc.DB.Packages

    var symbol:Symbol.Package { self.package }

    static
    var target:Mongo.AnyKeyPath { Unidoc.EditionState[.package] }

    func extend(pipeline:inout Mongo.PipelineEncoder)
    {
        pipeline.loadTags(matching: self.version,
            from: Unidoc.EditionState[.package],
            into: Unidoc.EditionState[.version])

        //  Unbox single-element array.
        pipeline[stage: .unwind] = Unidoc.EditionState[.version]

        pipeline[stage: .lookup] = .init
        {
            $0[.from] = Unidoc.DB.PackageBuilds.name
            $0[.localField] = Unidoc.EditionState[.package] / Unidoc.PackageMetadata[.id]
            $0[.foreignField] = Unidoc.BuildMetadata[.id]
            $0[.as] = Unidoc.EditionState[.build]
        }

        pipeline[stage: .set] = .init
        {
            $0[Unidoc.EditionState[.build]] = .expr
            {
                $0[.first] = Unidoc.EditionState[.build]
            }
        }
    }
}
