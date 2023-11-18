import BSON
import MongoQL
import Unidoc
import UnidocDB
import UnidocRecords

extension Volume
{
    /// A context mode that looks up all adjacent scalars and volumes.
    @frozen public
    enum LookupAdjacent
    {
    }
}
extension Volume.LookupAdjacent:Volume.LookupContext
{
    public static
    func groups(_ stage:inout Mongo.PipelineStage,
        volume:Mongo.KeyPath,
        vertex:Mongo.KeyPath,
        output:Mongo.KeyPath)
    {
        let extendee:Scalar = .init(in: vertex / Volume.Vertex[.extendee])

        stage[.lookup] = .init
        {
            let global:Mongo.Variable<Unidoc.Scalar> = "global"
            let local:Mongo.Variable<Unidoc.Scalar> = "local"
            let topic:Mongo.Variable<Unidoc.Scalar> = "topic"

            let min:Mongo.Variable<Unidoc.Scalar> = "min"
            let max:Mongo.Variable<Unidoc.Scalar> = "max"

            $0[.from] = UnidocDatabase.Groups.name
            $0[.let] = .init
            {
                $0[let: global] = .expr
                {
                    $0[.cond] =
                    (
                        if: extendee.missing,
                        then: .expr
                        {
                            $0[.coalesce] = (vertex / Volume.Vertex[.id], BSON.Max.init())
                        },
                        else: BSON.Max.init()
                    )
                }
                $0[let: local] = .expr
                {
                    $0[.coalesce] =
                    (
                        vertex / Volume.Vertex[.extendee],
                        vertex / Volume.Vertex[.id],
                        BSON.Max.init()
                    )
                }
                $0[let: topic] = .expr
                {
                    //  `BSON.max` is a safe choice for a group `_id` that will never
                    //  match anything.
                    $0[.coalesce] =
                    (
                        vertex / Volume.Vertex[.group],
                        BSON.Max.init()
                    )
                }
                $0[let: min] = volume / Volume.Meta[.planes_autogroup]
                $0[let: max] = volume / Volume.Meta[.planes_max]
            }
            $0[.pipeline] = .init
            {
                $0.stage
                {
                    //  Matches groups that have the same `_id` as `topic`, or that have
                    //  the same `scope` as `local` and are in the range `min` to `max`, or
                    //  that have the same `scope` as `global` and are marked as `latest`.
                    $0[.match] = .groups(id: topic,
                        or: (scope: local, min: min, max: max),
                        or: (scope: global, latest: true))
                }
            }
            $0[.as] = output
        }
    }

    public static
    func edges(_ stage:inout Mongo.PipelineStage,
        volume:Mongo.KeyPath,
        vertex:Mongo.KeyPath,
        groups:Mongo.KeyPath,
        output:(scalars:Mongo.KeyPath, volumes:Mongo.KeyPath))
    {
        stage[.set] = .init
        {
            let dependencies:Mongo.List<Volume.Meta.Dependency, Mongo.KeyPath> = .init(
                in: volume / Volume.Meta[.dependencies])
            let extensions:Mongo.List<Volume.Group, Mongo.KeyPath> = .init(
                in: groups)
            let adjacent:ScalarsView = .init(
                in: vertex)

            $0[output.volumes] = .expr
            {
                $0[.setUnion] = .init
                {
                    $0.expr { $0[.reduce] = extensions.flatMap(\.zones) }
                    $0.expr { $0[.map] = dependencies.map { $0[.resolution] } }
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
