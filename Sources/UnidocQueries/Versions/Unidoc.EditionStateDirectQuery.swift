import MongoDB
import UnidocAPI
import UnidocDB

extension Unidoc
{
    struct EditionStateDirectQuery
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
extension Unidoc.EditionStateDirectQuery:Mongo.PipelineQuery
{
    typealias CollectionOrigin = Unidoc.DB.Packages
    typealias Collation = SimpleCollation
    typealias Iteration = Mongo.Single<Unidoc.EditionState>

    var hint:Mongo.CollectionIndex? { nil }

    func build(pipeline:inout Mongo.PipelineEncoder)
    {
        pipeline[stage: .match]
        {
            $0[Unidoc.PackageMetadata[.id]] = self.package
        }
        pipeline[stage: .replaceWith] = .init(Unidoc.EditionState.CodingKey.self)
        {
            $0[.package] = Mongo.Pipeline.ROOT
        }

        switch self.version
        {
        case .match(let predicate):
            pipeline.loadTags(matching: predicate,
                from: Unidoc.EditionState[.package],
                into: Unidoc.EditionState[.version])

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

                    $0[stage: .replaceWith] = .init
                    {
                        $0[Unidoc.VersionState[.edition]] = Mongo.Pipeline.ROOT
                    }

                    $0.loadResources(associatedTo: Unidoc.VersionState[.edition] /
                            Unidoc.EditionMetadata[.id],
                        volume: Unidoc.VersionState[.volume],
                        graph: Unidoc.VersionState[.graph])
                }

                $0[.as] = Unidoc.EditionState[.version]
            }
        }

        //  Unbox single-element array.
        pipeline[stage: .unwind] = Unidoc.EditionState[.version]
    }
}
