import BSON
import MongoQL
import Unidoc
import UnidocDB
import UnidocRecords
import UnidocSelectors

@frozen public
struct WideQuery:Equatable, Hashable, Sendable
{
    public
    let volume:Volume.Selector
    public
    let lookup:Volume.Shoot

    @inlinable public
    init(volume:Volume.Selector, lookup:Volume.Shoot)
    {
        self.volume = volume
        self.lookup = lookup
    }
}
extension WideQuery:VolumeLookupQuery
{
    @inlinable public static
    var volumeOfLatest:Mongo.KeyPath? { Output.Principal[.volumeOfLatest] }
    @inlinable public static
    var volume:Mongo.KeyPath { Output.Principal[.volume] }

    @inlinable public static
    var input:Mongo.KeyPath { Output.Principal[.matches] }

    public
    func extend(pipeline:inout Mongo.Pipeline)
    {
        pipeline.stage
        {
            //  Populate this field only if exactly one vertex matched.
            //  This allows us to skip looking up secondary/tertiary records if
            //  we are only going to generate a disambiguation page.
            $0[.set] = .init
            {
                $0[Output.Principal[.vertex]] = .expr
                {
                    $0[.cond] =
                    (
                        if: .expr
                        {
                            $0[.eq] =
                            (
                                1, .expr { $0[.size] = Output.Principal[.matches] }
                            )
                        },
                        then: .expr { $0[.first] = Output.Principal[.matches] },
                        else: Never??.some(nil)
                    )
                }
            }
        }

        //  Lookup the repo-level information.
        pipeline.stage
        {
            $0[.lookup] = .init
            {
                $0[.from] = UnidocDatabase.Packages.name
                $0[.localField] = Output.Principal[.volume] / Volume.Meta[.cell]
                $0[.foreignField] = PackageRecord[.cell]
                $0[.as] = Output.Principal[.repo]
            }
        }
        //  Unbox single-element array and access element field.
        pipeline.stage
        {
            $0[.set] = .init
            {
                $0[Output.Principal[.repo]] = .expr { $0[.first] = Output.Principal[.repo] }
            }
        }
        pipeline.stage
        {
            $0[.set] = .init
            {
                $0[Output.Principal[.repo]] = Output.Principal[.repo] / PackageRecord[.repo]
            }
        }

        //  Look up the vertex in the volume of the latest stable release of its home package.
        //  The lookup correlates verticies by symbol.
        //
        //  This stage is a lot like the ``Symbol.Decl`` extension, but `symbol` and `hash`
        //  are variables obtained from the principal `vertex` record.
        pipeline.stage
        {
            $0[.lookup] = .init
            {
                let symbol:Mongo.Variable<Unidoc.Scalar> = "symbol"
                let hash:Mongo.Variable<Unidoc.Scalar> = "hash"

                let min:Mongo.Variable<Unidoc.Scalar> = "min"
                let max:Mongo.Variable<Unidoc.Scalar> = "max"

                $0[.from] = UnidocDatabase.Vertices.name
                $0[.let] = .init
                {
                    $0[let: symbol] = .expr
                    {
                        $0[.coalesce] =
                        (
                            Output.Principal[.vertex] / Volume.Vertex[.symbol],
                            BSON.Max.init()
                        )
                    }
                    $0[let: hash] = .expr
                    {
                        $0[.coalesce] =
                        (
                            Output.Principal[.vertex] / Volume.Vertex[.hash],
                            BSON.Max.init()
                        )
                    }
                    //  ``volumeOfLatest`` is always non-nil, so we don’t need to worry about
                    //  degenerate index behavior.
                    $0[let: min] = Output.Principal[.volumeOfLatest] / Volume.Meta[.planes_min]
                    $0[let: max] = Output.Principal[.volumeOfLatest] / Volume.Meta[.planes_max]
                }
                $0[.pipeline] = .init
                {
                    $0.stage
                    {
                        $0[.match] = .init
                        {
                            $0[.expr] = .expr
                            {
                                $0[.and] =
                                (
                                    //  The first three of these clauses should be able to use
                                    //  a compound index.
                                    .expr
                                    {
                                        $0[.eq] = (Volume.Vertex[.hash], hash)
                                    },
                                    .expr
                                    {
                                        $0[.gte] = (Volume.Vertex[.id], min)
                                    },
                                    .expr
                                    {
                                        $0[.lte] = (Volume.Vertex[.id], max)
                                    },

                                    .expr
                                    {
                                        $0[.eq] = (Volume.Vertex[.symbol], symbol)
                                    }
                                )
                            }
                        }
                    }
                    $0.stage
                    {
                        $0[.limit] = 1
                    }
                    $0.stage
                    {
                        //  We do not need to load *any* markdown for this record.
                        $0[.unset] =
                        [
                            Volume.Vertex[.requirements],
                            Volume.Vertex[.superforms],
                            Volume.Vertex[.overview],
                            Volume.Vertex[.details],
                        ]
                    }
                }
                $0[.as] = Output.Principal[.vertexInLatest]
            }
        }
        //  Unbox single-element array.
        pipeline.stage
        {
            $0[.set] = .init
            {
                $0[Output.Principal[.vertexInLatest]] = .expr
                {
                    $0[.first] = Output.Principal[.vertexInLatest]
                }
            }
        }

        let extendee:AdjacentScalar = .init(
            in: Output.Principal[.vertex] / Volume.Vertex[.extendee])

        //  Gather all the extensions to the principal vertex.
        pipeline.stage
        {
            $0[.lookup] = .init
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
                                $0[.coalesce] =
                                (
                                    Output.Principal[.vertex] / Volume.Vertex[.id],
                                    BSON.Max.init()
                                )
                            },
                            else: BSON.Max.init()
                        )
                    }
                    $0[let: local] = .expr
                    {
                        $0[.coalesce] =
                        (
                            Output.Principal[.vertex] / Volume.Vertex[.extendee],
                            Output.Principal[.vertex] / Volume.Vertex[.id],
                            BSON.Max.init()
                        )
                    }
                    $0[let: topic] = .expr
                    {
                        //  `BSON.max` is a safe choice for a group `_id` that will never
                        //  match anything.
                        $0[.coalesce] =
                        (
                            Output.Principal[.vertex] / Volume.Vertex[.group],
                            BSON.Max.init()
                        )
                    }
                    $0[let: min] = Output.Principal[.volume] / Volume.Meta[.planes_autogroup]
                    $0[let: max] = Output.Principal[.volume] / Volume.Meta[.planes_max]
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
                $0[.as] = Output.Principal[.groups]
            }
        }

        //  Extract (and de-duplicate) the scalars mentioned by the extensions.
        //  Store them in this temporary field:
        let scalars:Mongo.KeyPath = "scalars"
        //  The extensions have precomputed volume ids for MongoDB’s convenience.
        let volumes:Mongo.KeyPath = "volumes"

        pipeline.stage
        {
            $0[.set] = .init
            {
                let dependencies:Mongo.List<Volume.Meta.Dependency, Mongo.KeyPath> = .init(
                    in: Output.Principal[.volume] / Volume.Meta[.dependencies])
                let extensions:Mongo.List<Volume.Group, Mongo.KeyPath> = .init(
                    in: Output.Principal[.groups])
                let adjacent:AdjacentScalarsView = .init(
                    in: Output.Principal[.vertex])

                $0[volumes] = .expr
                {
                    $0[.setUnion] = .init
                    {
                        $0.expr { $0[.reduce] = extensions.flatMap(\.zones) }
                        $0.expr { $0[.map] = dependencies.map { $0[.resolution] } }
                    }
                }
                $0[scalars] = .expr
                {
                    $0[.setUnion] = .init
                    {
                        $0.expr { $0[.reduce] = extensions.flatMap(\.scalars) }
                        $0 += adjacent
                    }
                }
            }
        }
        //  The `$facet` stage in ``pipeline`` should collect all records into a
        //  single document, so this pipeline should return at most 1 element.
        pipeline.stage
        {
            $0[.facet] = .init
            {
                $0[Output[.principal]] = .init
                {
                    $0.stage
                    {
                        $0[.project] = .init
                        {
                            for key:Output.Principal.CodingKey in
                            [
                                .matches,
                                .vertex,
                                .vertexInLatest,
                                .groups,
                                .repo,
                            ]
                            {
                                $0[Output.Principal[key]] = true
                            }
                            for volume:Output.Principal.CodingKey in
                            [
                                .volume,
                                .volumeOfLatest,
                            ]
                            {
                                //  Do not return computed fields.
                                for key:Volume.Meta.CodingKey in
                                [
                                    .id,
                                    .dependencies,
                                    .package,
                                    .version,
                                    .display,
                                    .refname,
                                    .commit,
                                    .patch,

                                    //  TODO: we only need this for top-level queries!
                                    .link,
                                    //  TODO: we only need this for top-level queries and
                                    //  foreign vertices!
                                    .tree,

                                    .latest,
                                    .api
                                ]
                                {
                                    $0[Output.Principal[volume] / Volume.Meta[key]] = true
                                }
                            }
                        }
                    }
                    $0.stage
                    {
                        $0[.lookup] = .init
                        {
                            let tree:Mongo.Variable<Unidoc.Scalar> = "tree"

                            $0[.from] = UnidocDatabase.Trees.name
                            $0[.let] = .init
                            {
                                $0[let: tree] = .expr
                                {
                                    //  ``Volume.Vertex.Culture`` doesn’t have a `culture`
                                    //  field, but we still want to get the type tree for
                                    //  its `_id`. The ``Database.Trees`` collection only
                                    //  contains type trees, so it’s okay if the `_id` is
                                    //  not a culture.
                                    $0[.coalesce] =
                                    (
                                        Output.Principal[.vertex] / Volume.Vertex[.culture],
                                        Output.Principal[.vertex] / Volume.Vertex[.id],
                                        BSON.Max.init()
                                    )
                                }
                            }
                            $0[.pipeline] = .init
                            {
                                $0.stage
                                {
                                    $0[.match] = .init
                                    {
                                        $0[.expr] = .expr
                                        {
                                            $0[.eq] = (Volume.TypeTree[.id], tree)
                                        }
                                    }
                                }
                            }
                            $0[.as] = Output.Principal[.tree]
                        }
                    }
                    $0.stage
                    {
                        //  Unbox single-element array.
                        $0[.set] = .init
                        {
                            $0[Output.Principal[.tree]] = .expr
                            {
                                $0[.first] = Output.Principal[.tree]
                            }
                        }
                    }
                }
                $0[Output[.vertices]] = .init
                {
                    let results:Mongo.KeyPath = "results"

                    $0.stage
                    {
                        $0[.unwind] = scalars
                    }
                    $0.stage
                    {
                        $0[.match] = .init
                        {
                            $0[scalars] = .init { $0[.ne] = Never??.some(nil) }
                        }
                    }
                    $0.stage
                    {
                        $0[.lookup] = .init
                        {
                            $0[.from] = UnidocDatabase.Vertices.name
                            $0[.localField] = scalars
                            $0[.foreignField] = Volume.Vertex[.id]
                            $0[.as] = results
                        }
                    }
                    $0.stage
                    {
                        $0[.unwind] = results
                    }
                    $0.stage
                    {
                        $0[.replaceWith] = results
                    }
                    $0.stage
                    {
                        //  We do not need to load all the markdown for secondary vertices.
                        $0[.unset] =
                        [
                            Volume.Vertex[.requirements],
                            Volume.Vertex[.superforms],
                            Volume.Vertex[.details],
                        ]
                    }
                }
                $0[Output[.volumes]] = .init
                {
                    let results:Mongo.KeyPath = "results"

                    $0.stage
                    {
                        $0[.unwind] = volumes
                    }
                    $0.stage
                    {
                        $0[.match] = .init
                        {
                            $0[.and] = .init
                            {
                                $0.append
                                {
                                    $0[volumes] = .init { $0[.ne] = .some(nil as Never?) }
                                }
                                $0.append
                                {
                                    $0[volumes] = .init
                                    {
                                        $0[.ne] = Output.Principal[.volume] / Volume.Meta[.id]
                                    }
                                }
                            }
                        }
                    }
                    $0.stage
                    {
                        $0[.lookup] = .init
                        {
                            $0[.from] = UnidocDatabase.Volumes.name
                            $0[.localField] = volumes
                            $0[.foreignField] = Volume.Meta[.id]
                            $0[.as] = results
                        }
                    }
                    $0.stage
                    {
                        $0[.unwind] = results
                    }
                    $0.stage
                    {
                        $0[.replaceWith] = results
                    }
                    $0.stage
                    {
                        $0[.project] = .init(with: Volume.Meta.names(_:))
                    }
                }
            }
        }
        //  Unbox single-element arrays.
        pipeline.stage
        {
            $0[.set] = .init
            {
                $0[Output[.principal]] = .expr { $0[.first] = Output[.principal] }
            }
        }
    }
}
