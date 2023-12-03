import BSON
import MongoDB
import MongoQL
import Unidoc
import UnidocDB
import UnidocRecords
import UnidocSelectors

@available(*, deprecated, renamed: "Volume.LookupQuery")
public
typealias WideQuery = Volume.LookupQuery

extension Volume
{
    /// Performs a vertex query within a volume, with additional lookups as determined by
    /// the specialized `Context`.
    ///
    /// The `Type` parameter allows you to transmit type information to the ``LookupOutput``.
    /// If no type information is needed, use `Any`.
    @frozen public
    struct LookupQuery<Context, Type>:Equatable, Hashable, Sendable
        where Context:Volume.LookupContext
    {
        public
        let volume:Volume.Selector
        public
        let vertex:Volume.Shoot

        @inlinable public
        init(volume:Volume.Selector, lookup vertex:Volume.Shoot)
        {
            self.volume = volume
            self.vertex = vertex
        }
    }
}
extension Volume.LookupQuery:Mongo.PipelineQuery
{
    public
    typealias Iteration = Mongo.Single<Volume.LookupOutput<Type>>
}
extension Volume.LookupQuery:Volume.VertexQuery
{
    @inlinable public static
    var volumeOfLatest:Mongo.KeyPath? { Volume.PrincipalOutput[.volumeOfLatest] }
    @inlinable public static
    var volume:Mongo.KeyPath { Volume.PrincipalOutput[.volume] }

    @inlinable public static
    var input:Mongo.KeyPath { Volume.PrincipalOutput[.matches] }

    public
    func extend(pipeline:inout Mongo.PipelineEncoder)
    {
        //  Populate this field only if exactly one vertex matched.
        //  This allows us to skip looking up secondary/tertiary records if
        //  we are only going to generate a disambiguation page.
        pipeline[.set] = .init
        {
            $0[Volume.PrincipalOutput[.vertex]] = .expr
            {
                $0[.cond] =
                (
                    if: .expr
                    {
                        $0[.eq] =
                        (
                            1, .expr { $0[.size] = Volume.PrincipalOutput[.matches] }
                        )
                    },
                    then: .expr { $0[.first] = Volume.PrincipalOutput[.matches] },
                    else: Never??.some(nil)
                )
            }
        }

        //  Lookup the repo-level information.
        pipeline[.lookup] = .init
        {
            $0[.from] = UnidocDatabase.Packages.name
            $0[.localField] = Volume.PrincipalOutput[.volume] / Volume.Metadata[.cell]
            $0[.foreignField] = Realm.Package[.id]
            $0[.as] = Volume.PrincipalOutput[.repo]
        }

        //  Unbox single-element array and access element field.
        pipeline[.set] = .init
        {
            $0[Volume.PrincipalOutput[.repo]] = .expr
            {
                $0[.first] = Volume.PrincipalOutput[.repo]
            }
        }
        pipeline[.set] = .init
        {
            $0[Volume.PrincipalOutput[.repo]] =
                Volume.PrincipalOutput[.repo] / Realm.Package[.repo]
        }

        //  Look up the vertex in the volume of the latest stable release of its home package.
        //  The lookup correlates verticies by symbol.
        //
        //  This stage is a lot like the ``Symbol.Decl`` extension, but `symbol` and `hash`
        //  are variables obtained from the principal `vertex` record.
        pipeline[.lookup] = .init
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
                        Volume.PrincipalOutput[.vertex] / Volume.Vertex[.symbol],
                        BSON.Max.init()
                    )
                }
                $0[let: hash] = .expr
                {
                    $0[.coalesce] =
                    (
                        Volume.PrincipalOutput[.vertex] / Volume.Vertex[.hash],
                        BSON.Max.init()
                    )
                }
                //  ``volumeOfLatest`` is always non-nil, so we don’t need to worry about
                //  degenerate index behavior.
                $0[let: min] =
                    Volume.PrincipalOutput[.volumeOfLatest] / Volume.Metadata[.planes_min]
                $0[let: max] =
                    Volume.PrincipalOutput[.volumeOfLatest] / Volume.Metadata[.planes_max]
            }
            $0[.pipeline] = .init
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

                $0[.limit] = 1

                //  We do not need to load *any* markdown for this record.
                $0[.unset] =
                [
                    Volume.Vertex[.requirements],
                    Volume.Vertex[.superforms],
                    Volume.Vertex[.overview],
                    Volume.Vertex[.details],
                ]
            }
            $0[.as] = Volume.PrincipalOutput[.vertexInLatest]
        }
        //  Unbox single-element array.
        pipeline[.set] = .init
        {
            $0[Volume.PrincipalOutput[.vertexInLatest]] = .expr
            {
                $0[.first] = Volume.PrincipalOutput[.vertexInLatest]
            }
        }

        //  Gather all the extensions to the principal vertex.
        Context.groups(&pipeline,
            volume: Volume.PrincipalOutput[.volume],
            vertex: Volume.PrincipalOutput[.vertex],
            output: Volume.PrincipalOutput[.groups])

        //  Extract (and de-duplicate) the scalars and volumes mentioned by the extensions.
        //  The extensions have precomputed volume ids for MongoDB’s convenience.
        let edges:(scalars:Mongo.KeyPath, volumes:Mongo.KeyPath) = ("scalars", "volumes")

        Context.edges(&pipeline,
            volume: Volume.PrincipalOutput[.volume],
            vertex: Volume.PrincipalOutput[.vertex],
            groups: Volume.PrincipalOutput[.groups],
            output: edges)

        //  The `$facet` stage in ``pipeline`` should collect all records into a
        //  single document, so this pipeline should return at most 1 element.
        pipeline[.facet] = .init
        {
            $0[Volume.LookupOutput<Type>[.principal]] = .init
            {
                $0[.project] = .init
                {
                    for key:Volume.PrincipalOutput.CodingKey in
                    [
                        .matches,
                        .vertex,
                        .vertexInLatest,
                        .groups,
                        .repo,
                    ]
                    {
                        $0[Volume.PrincipalOutput[key]] = true
                    }
                    for volume:Volume.PrincipalOutput.CodingKey in
                    [
                        .volume,
                        .volumeOfLatest,
                    ]
                    {
                        //  Do not return computed fields.
                        for key:Volume.Metadata.CodingKey in
                        [
                            .id,
                            .dependencies,
                            .package,
                            .version,
                            .display,
                            .refname,
                            .commit,
                            .patch,

                            //  TODO: we only need this for top-level queries and
                            //  foreign vertices!
                            .tree,

                            .latest,
                            .realm,
                            .api
                        ]
                        {
                            $0[Volume.PrincipalOutput[volume] / Volume.Metadata[key]] = true
                        }
                    }
                }
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
                                Volume.PrincipalOutput[.vertex] / Volume.Vertex[.culture],
                                Volume.PrincipalOutput[.vertex] / Volume.Vertex[.id],
                                BSON.Max.init()
                            )
                        }
                    }
                    $0[.pipeline] = .init
                    {
                        $0[.match] = .init
                        {
                            $0[.expr] = .expr
                            {
                                $0[.eq] = (Volume.TypeTree[.id], tree)
                            }
                        }
                    }
                    $0[.as] = Volume.PrincipalOutput[.tree]
                }
                //  Unbox single-element array.
                $0[.set] = .init
                {
                    $0[Volume.PrincipalOutput[.tree]] = .expr
                    {
                        $0[.first] = Volume.PrincipalOutput[.tree]
                    }
                }
            }

            $0[Volume.LookupOutput<Type>[.vertices]] = .init
            {
                let results:Mongo.KeyPath = "results"

                $0[.unwind] = edges.scalars
                $0[.match] = .init
                {
                    $0[edges.scalars] = .init { $0[.ne] = Never??.some(nil) }
                }
                $0[.lookup] = .init
                {
                    $0[.from] = UnidocDatabase.Vertices.name
                    $0[.localField] = edges.scalars
                    $0[.foreignField] = Volume.Vertex[.id]
                    $0[.as] = results
                }
                $0[.unwind] = results
                $0[.replaceWith] = results
                //  We do not need to load all the markdown for secondary vertices.
                $0[.unset] =
                [
                    Volume.Vertex[.requirements],
                    Volume.Vertex[.superforms],
                    Volume.Vertex[.details],
                ]
            }

            $0[Volume.LookupOutput<Type>[.volumes]] = .init
            {
                let results:Mongo.KeyPath = "results"

                $0[.unwind] = edges.volumes
                $0[.match] = .init
                {
                    $0[.and] = .init
                    {
                        $0.append
                        {
                            $0[edges.volumes] = .init { $0[.ne] = .some(nil as Never?) }
                        }
                        $0.append
                        {
                            $0[edges.volumes] = .init
                            {
                                $0[.ne] = Volume.PrincipalOutput[.volume] / Volume.Metadata[.id]
                            }
                        }
                    }
                }
                $0[.lookup] = .init
                {
                    $0[.from] = UnidocDatabase.Volumes.name
                    $0[.localField] = edges.volumes
                    $0[.foreignField] = Volume.Metadata[.id]
                    $0[.as] = results
                }
                $0[.unwind] = results
                $0[.replaceWith] = results
                $0[.project] = .init(with: Volume.Metadata.names(_:))
            }
        }
        //  Unbox single-element arrays.
        pipeline[.set] = .init
        {
            $0[Volume.LookupOutput<Type>[.principal]] = .expr
            {
                $0[.first] = Volume.LookupOutput<Type>[.principal]
            }
        }
    }
}
