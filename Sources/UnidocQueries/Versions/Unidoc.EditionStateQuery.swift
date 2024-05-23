import MongoDB
import UnidocAPI
import UnidocDB

extension Unidoc
{
    struct EditionStateQuery
    {
        let package:Package
        let version:VersionSelector

        let builds:Bool

        init(package:Package, version:VersionSelector, builds:Bool = false)
        {
            self.package = package
            self.version = version
            self.builds = builds
        }
    }
}
extension Unidoc.EditionStateQuery:Mongo.PipelineQuery
{
    typealias CollectionOrigin = Unidoc.DB.Packages
    typealias Collation = SimpleCollation
    typealias Iteration = Mongo.Single<Unidoc.EditionState>

    var hint:Mongo.CollectionIndex? { nil }

    func build(pipeline:inout Mongo.PipelineEncoder)
    {
        pipeline[stage: .match] = .init
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

            pipeline[stage: .lookup] = .init
            {
                $0[.from] = Unidoc.DB.Editions.name
                $0[.pipeline] = .init
                {
                    $0[stage: .match] = .init
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

        if  self.builds
        {
            pipeline[stage: .lookup] = .init
            {
                $0[.from] = Unidoc.DB.PackageBuilds.name
                $0[.pipeline] = .init
                {
                    $0[stage: .match] = .init
                    {
                        $0[Unidoc.BuildMetadata[.id]] = self.package
                    }
                }
                $0[.as] = Unidoc.EditionState[.builds]
            }
        }
    }
}
