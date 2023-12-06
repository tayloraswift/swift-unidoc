import MongoQL
import Unidoc
import UnidocRecords

struct PlaceEditionQuery:Sendable
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
extension PlaceEditionQuery:Mongo.PipelineQuery
{
    typealias CollectionOrigin = UnidocDatabase.Editions
    typealias Collation = SimpleCollation
    typealias Iteration = Mongo.Single<Realm.EditionPlacement>

    var hint:Mongo.CollectionIndex? { nil }

    func build(pipeline:inout Mongo.PipelineEncoder)
    {
        let new:Mongo.KeyPath = "new"
        let old:Mongo.KeyPath = "old"
        let all:Mongo.KeyPath = "all"

        pipeline[.match] = .init
        {
            $0[Realm.Edition[.package]] = package
        }
        pipeline[.facet] = .init
        {
            $0[old] = .init
            {
                $0[.match] = .init
                {
                    $0[Realm.Edition[.name]] = refname
                }

                $0[.replaceWith] = .init
                {
                    $0[Realm.EditionPlacement[.edition]] = Mongo.Pipeline.ROOT
                }
            }
            $0[new] = .init
            {
                $0[.sort] = .init
                {
                    $0[Realm.Edition[.version]] = (-)
                }

                $0[.limit] = 1

                $0[.replaceWith] = .init
                {
                    $0[Realm.EditionPlacement[.coordinate]] = .expr
                    {
                        $0[.add] = (Realm.Edition[.version], 1)
                    }
                }
            }
        }

        pipeline[.set] = .init
        {
            $0[all] = .expr { $0[.concatArrays] = (old, new) }
        }

        pipeline[.unwind] = all
        pipeline[.replaceWith] = all
        pipeline[.limit] = 1
    }
}
