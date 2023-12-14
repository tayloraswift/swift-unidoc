import BSON
import MongoQL
import Unidoc
import UnidocDB
import UnidocRecords

extension Unidoc
{
    /// A context mode that looks up all adjacent scalars and volumes.
    @frozen public
    enum LookupAdjacent
    {
    }
}
extension Unidoc.LookupAdjacent:Unidoc.LookupContext
{
    public static
    func groups(_ pipeline:inout Mongo.PipelineEncoder,
        volume:Mongo.KeyPath,
        vertex:Mongo.KeyPath,
        output:Mongo.KeyPath)
    {
        let extendee:Scalar = .init(in: vertex / Unidoc.Vertex[.extendee])

        pipeline[.lookup] = .init
        {
            let `extension`:Group = .init(id: "extension")
            let topic:Group = .init(id: "topic")

            let local:LockedExtensions = .init(scope: "local", min: "min", max: "max")
            let realm:LatestExtensions = .init(scope: "scope", id: "realm")

            $0[.from] = UnidocDatabase.Groups.name
            $0[.let] = .init
            {
                $0[let: `extension`.id] = .expr
                {
                    //  `BSON.max` is a safe choice for a group `_id` that will never
                    //  match anything.
                    $0[.coalesce] = (vertex / Unidoc.Vertex[.extension], BSON.Max.init())
                }
                $0[let: topic.id] = .expr
                {
                    $0[.coalesce] = (vertex / Unidoc.Vertex[.group], BSON.Max.init())
                }

                $0[let: local.scope] = .expr
                {
                    $0[.coalesce] =
                    (
                        vertex / Unidoc.Vertex[.extendee],
                        vertex / Unidoc.Vertex[.id],
                        BSON.Max.init()
                    )
                }
                $0[let: realm.scope] = .expr
                {
                    $0[.cond] =
                    (
                        if: extendee.missing,
                        then: .expr
                        {
                            $0[.coalesce] = (vertex / Unidoc.Vertex[.id], BSON.Max.init())
                        },
                        else: BSON.Max.init()
                    )
                }
                //  We probably don’t need this, the `Groups` collection doesn’t overlap
                //  with the `Vertices` collection.
                $0[let: local.min] = volume / Unidoc.VolumeMetadata[.planes_autogroup]
                $0[let: local.max] = volume / Unidoc.VolumeMetadata[.planes_max]

                $0[let: realm.id] = .expr
                {
                    $0[.coalesce] = (volume / Unidoc.VolumeMetadata[.realm], BSON.Max.init())
                }
            }
            $0[.pipeline] = .init
            {
                $0[.match] = .init
                {
                    $0[.expr] = .expr
                    {
                        $0[.or] = .init
                        {
                            $0 += `extension`
                            $0 += topic
                            $0 += local
                            $0 += realm
                        }
                    }
                }
            }
            $0[.as] = output
        }
    }

    public static
    func edges(_ pipeline:inout Mongo.PipelineEncoder,
        volume:Mongo.KeyPath,
        vertex:Mongo.KeyPath,
        groups:Mongo.KeyPath,
        output:(scalars:Mongo.KeyPath, volumes:Mongo.KeyPath))
    {
        pipeline[.set] = .init
        {
            let dependencies:Mongo.List<Unidoc.VolumeMetadata.Dependency, Mongo.KeyPath> = .init(
                in: volume / Unidoc.VolumeMetadata[.dependencies])
            let extensions:Mongo.List<Unidoc.Group, Mongo.KeyPath> = .init(
                in: groups)
            let adjacent:ScalarsView = .init(
                in: vertex)

            $0[output.volumes] = .expr
            {
                $0[.setUnion] = .init
                {
                    $0.expr { $0[.reduce] = extensions.flatMap(\.zones) }
                    $0.expr { $0[.map] = dependencies.map { $0[.pinned] } }
                }
            }
            $0[output.scalars] = .expr
            {
                $0[.setUnion] = .init
                {
                    $0.expr { $0[.reduce] = extensions.flatMap(\.scalars) }
                    $0 += adjacent
                }
            }
        }
    }
}
