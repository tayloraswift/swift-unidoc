import MongoDB
import UnidocAPI
import UnidocDB

extension Unidoc
{
    /// Note that this query does not return information about builds.
    struct RefStateDirectQuery
    {
        let package:Package
        let version:VersionSelector

        init(package:Package, version:VersionSelector)
        {
            self.package = package
            self.version = version
        }
    }
}
extension Unidoc.RefStateDirectQuery:Mongo.PipelineQuery
{
    typealias Iteration = Mongo.Single<Unidoc.RefState>

    var collation:Mongo.Collation { .simple }
    var from:Mongo.Collection? { Unidoc.DB.Packages.name }
    var hint:Mongo.CollectionIndex? { nil }

    func build(pipeline:inout Mongo.PipelineEncoder)
    {
        pipeline[stage: .match]
        {
            $0[Unidoc.PackageMetadata[.id]] = self.package
        }
        pipeline[stage: .replaceWith, using: Unidoc.RefState.CodingKey.self]
        {
            $0[.package] = Mongo.Pipeline.ROOT
        }

        switch self.version
        {
        case .match(let predicate):
            pipeline.loadTags(matching: predicate,
                from: Unidoc.RefState[.package],
                into: Unidoc.RefState[.version])

        case .exact(let id):
            let id:Unidoc.Edition = .init(package: self.package, version: id)

            pipeline[stage: .lookup]
            {
                $0[.from] = Unidoc.DB.Editions.name
                $0[.pipeline]
                {
                    $0[stage: .match]
                    {
                        $0[Unidoc.EditionMetadata[.id]] = id
                    }

                    $0[stage: .replaceWith, using: Unidoc.VersionState.CodingKey.self]
                    {
                        $0[.edition] = Mongo.Pipeline.ROOT
                    }

                    $0.loadResources(associatedTo: Unidoc.VersionState[.edition] /
                            Unidoc.EditionMetadata[.id],
                        volume: Unidoc.VersionState[.volume],
                        graph: Unidoc.VersionState[.graph])
                }

                $0[.as] = Unidoc.RefState[.version]
            }
        }

        //  Unbox single-element array.
        pipeline[stage: .unwind] = Unidoc.RefState[.version]

        pipeline.loadUser(
            owning: Unidoc.RefState[.package],
            as: Unidoc.RefState[.owner])
    }
}
