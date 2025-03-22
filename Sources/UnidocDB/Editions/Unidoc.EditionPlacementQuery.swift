import MongoQL
import Unidoc
import UnidocRecords

extension Unidoc
{
    struct EditionPlacementQuery:Sendable
    {
        private
        let package:Unidoc.Package
        private
        let refname:String

        init(package:Unidoc.Package, refname:String)
        {
            self.package = package
            self.refname = refname
        }
    }
}
extension Unidoc.EditionPlacementQuery:Mongo.PipelineQuery
{
    typealias Iteration = Mongo.Single<Unidoc.EditionPlacement>

    var collation:Mongo.Collation { .simple }
    var from:Mongo.Collection? { Unidoc.DB.Editions.name }
    var hint:Mongo.CollectionIndex? { nil }

    func build(pipeline:inout Mongo.PipelineEncoder)
    {
        let new:Mongo.AnyKeyPath = "new"
        let old:Mongo.AnyKeyPath = "old"
        let all:Mongo.AnyKeyPath = "all"

        pipeline[stage: .match]
        {
            $0[Unidoc.EditionMetadata[.package]] = package
        }
        pipeline[stage: .facet]
        {
            $0[old]
            {
                $0[stage: .match]
                {
                    $0[Unidoc.EditionMetadata[.name]] = refname
                }

                $0[stage: .replaceWith, using: Unidoc.EditionPlacement.CodingKey.self]
                {
                    $0[.edition] = Mongo.Pipeline.ROOT
                }
            }
            $0[new]
            {
                $0[stage: .sort, using: Unidoc.EditionMetadata.CodingKey.self]
                {
                    $0[.version] = (-)
                }

                $0[stage: .limit] = 1

                $0[stage: .replaceWith, using: Unidoc.EditionPlacement.CodingKey.self]
                {
                    $0[.coordinate] { $0[.add] = (Unidoc.EditionMetadata[.version], 1) }
                }
            }
        }

        pipeline[stage: .set]
        {
            $0[all] { $0[.concatArrays] = (old, new) }
        }

        pipeline[stage: .unwind] = all
        pipeline[stage: .replaceWith] = all
        pipeline[stage: .limit] = 1
    }
}
