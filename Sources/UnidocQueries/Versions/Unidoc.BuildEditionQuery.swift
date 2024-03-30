import MongoQL
import SymbolGraphs
import UnidocDB

extension Unidoc
{
    struct BuildEditionQuery
    {
        let edition:Unidoc.Edition

        init(edition:Unidoc.Edition)
        {
            self.edition = edition
        }
    }
}
extension Unidoc.BuildEditionQuery:Mongo.PipelineQuery
{
    typealias CollectionOrigin = Unidoc.DB.Packages
    typealias Collation = SimpleCollation
    typealias Iteration = Mongo.Single<Output>

    var hint:Mongo.CollectionIndex? { nil }

    func build(pipeline:inout Mongo.PipelineEncoder)
    {
        pipeline[stage: .match] = .init
        {
            $0[Unidoc.PackageMetadata[.id]] = self.edition.package
        }
        pipeline[stage: .replaceWith] = .init
        {
            $0[Output[.package]] = Mongo.Pipeline.ROOT
        }

        pipeline[stage: .lookup] = .init
        {
            $0[.from] = Unidoc.DB.Editions.name

            $0[.pipeline] = .init
            {
                $0[stage: .match] = .init
                {
                    $0[Unidoc.EditionMetadata[.id]] = self.edition
                }
            }

            $0[.as] = Output[.edition]
        }

        pipeline[stage: .unwind] = Output[.edition]
    }
}
