import BSON
import MongoQL
import Unidoc
import UnidocDB
import UnidocRecords

extension Unidoc
{
    /// A context mode that looks up all adjacent scalars and volumes.
    @frozen public
    struct LookupAdjacent:Sendable
    {
        public
        let layer:GroupLayer?

        @inlinable
        init(layer:GroupLayer?)
        {
            self.layer = layer
        }
    }
}
extension Unidoc.LookupAdjacent:Unidoc.LookupContext
{
    public
    func groups(_ pipeline:inout Mongo.PipelineEncoder,
        volume:Mongo.AnyKeyPath,
        vertex:Mongo.AnyKeyPath,
        output:Mongo.AnyKeyPath)
    {
        let extendee:Mongo.OptionalKeyPath = .init(in: vertex / Unidoc.AnyVertex[.extendee])

        pipeline[stage: .lookup] = .init
        {
            let special:SpecialGroups

            switch self.layer
            {
            case .protocols?:   special = .protocols
            default:            special = .default(.init(peers: "peers", topic: "topic"))
            }

            let local:LockedExtensions = .init(layer: self.layer,
                scope: "local",
                min: "min",
                max: "max")
            let realm:LatestExtensions = .init(layer: self.layer,
                scope: "scope",
                id: "realm")

            $0[.from] = Unidoc.DB.Groups.name
            $0[.let] = .init
            {
                $0[let: local.scope] = .expr
                {
                    $0[.coalesce] =
                    (
                        vertex / Unidoc.AnyVertex[.extendee],
                        vertex / Unidoc.AnyVertex[.id],
                        BSON.Max.init()
                    )
                }
                $0[let: realm.scope] = .expr
                {
                    $0[.cond] =
                    (
                        if: extendee.null,
                        then: .expr
                        {
                            $0[.coalesce] = (vertex / Unidoc.AnyVertex[.id], BSON.Max.init())
                        },
                        else: BSON.Max.init()
                    )
                }

                $0[let: local.min] = volume / Unidoc.VolumeMetadata[.min]
                $0[let: local.max] = volume / Unidoc.VolumeMetadata[.max]

                $0[let: realm.id] = .expr
                {
                    $0[.coalesce] = (volume / Unidoc.VolumeMetadata[.realm], BSON.Max.init())
                }

                guard
                case .default(let special) = special
                else
                {
                    return
                }

                $0[let: special.peers] = .expr
                {
                    //  `BSON.max` is a safe choice for a group `_id` that will never
                    //  match anything.
                    $0[.coalesce] = (vertex / Unidoc.AnyVertex[.peers], BSON.Max.init())
                }
                $0[let: special.topic] = .expr
                {
                    $0[.coalesce] = (vertex / Unidoc.AnyVertex[.group], BSON.Max.init())
                }
            }
            $0[.pipeline] = .init
            {
                $0[stage: .match] = .init
                {
                    $0[.or] = .init
                    {
                        $0 += local
                        $0 += realm
                        $0 += special
                    }
                }
            }
            $0[.as] = output
        }
    }

    public
    func edges(_ pipeline:inout Mongo.PipelineEncoder,
        volume:Mongo.AnyKeyPath,
        vertex:Mongo.AnyKeyPath,
        groups:Mongo.AnyKeyPath,
        output:(scalars:Mongo.AnyKeyPath, volumes:Mongo.AnyKeyPath))
    {
        pipeline[stage: .set] = .init
        {
            $0[output.volumes] = .expr
            {
                let adjacent:Volumes = .init(
                    upstream: .init(in: volume / Unidoc.VolumeMetadata[.dependencies]),
                    groups: .init(in: groups))

                $0[.setUnion] = .init { $0 += adjacent }
            }
            $0[output.scalars] = .expr
            {
                let adjacent:Vertices = .init(layer: self.layer,
                    groups: .init(in: groups),
                    vertex: vertex)

                $0[.setUnion] = .init  { $0 += adjacent }
            }
        }
    }
}
