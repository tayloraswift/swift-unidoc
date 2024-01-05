import BSON
import MongoDB
import MongoQL
import Unidoc
import UnidocAPI
import UnidocDB
import UnidocRecords

@available(*, deprecated, renamed: "Unidoc.VertexQuery")
public
typealias WideQuery = Unidoc.VertexQuery

extension Unidoc
{
    /// Performs a vertex query within a volume, with additional lookups as determined by
    /// the specialized `Context`.
    ///
    /// The `Type` parameter allows you to transmit type information to the ``LookupOutput``.
    /// If no type information is needed, use `Any`.
    @frozen public
    struct VertexQuery<Context>:Equatable, Hashable, Sendable
        where Context:Unidoc.LookupContext
    {
        public
        let volume:VolumeSelector
        public
        let vertex:Shoot

        @inlinable public
        init(volume:VolumeSelector, lookup vertex:Shoot)
        {
            self.volume = volume
            self.vertex = vertex
        }
    }
}
extension Unidoc.VertexQuery:Mongo.PipelineQuery
{
    public
    typealias Iteration = Mongo.Single<Unidoc.VertexOutput>
}
extension Unidoc.VertexQuery:Unidoc.VolumeQuery
{
    /// The compiler is capable of inferring this on its own, but this makes it easier to
    /// understand how this type witnesses ``Unidoc.VolumeQuery``.
    public
    typealias VertexPredicate = Unidoc.Shoot

    @inlinable public static
    var volumeOfLatest:Mongo.KeyPath? { Unidoc.PrincipalOutput[.volumeOfLatest] }
    @inlinable public static
    var volume:Mongo.KeyPath { Unidoc.PrincipalOutput[.volume] }

    @inlinable public static
    var input:Mongo.KeyPath { Unidoc.PrincipalOutput[.matches] }

    public
    func extend(pipeline:inout Mongo.PipelineEncoder)
    {
        //  Populate this field only if exactly one vertex matched.
        //  This allows us to skip looking up secondary/tertiary records if
        //  we are only going to generate a disambiguation page.
        pipeline[.set] = .init
        {
            $0[Unidoc.PrincipalOutput[.vertex]] = .expr
            {
                $0[.cond] =
                (
                    if: .expr
                    {
                        $0[.eq] =
                        (
                            1, .expr { $0[.size] = Unidoc.PrincipalOutput[.matches] }
                        )
                    },
                    then: .expr { $0[.first] = Unidoc.PrincipalOutput[.matches] },
                    else: Never??.some(nil)
                )
            }
        }

        //  Lookup the repo-level information.
        pipeline[.lookup] = .init
        {
            $0[.from] = UnidocDatabase.Packages.name
            $0[.localField] = Unidoc.PrincipalOutput[.volume] / Unidoc.VolumeMetadata[.cell]
            $0[.foreignField] = Unidoc.PackageMetadata[.id]
            $0[.as] = Unidoc.PrincipalOutput[.repo]
        }

        //  Unbox single-element array and access element field.
        pipeline[.set] = .init
        {
            $0[Unidoc.PrincipalOutput[.repo]] = .expr
            {
                $0[.first] = Unidoc.PrincipalOutput[.repo]
            }
        }
        pipeline[.set] = .init
        {
            $0[Unidoc.PrincipalOutput[.repo]] =
                Unidoc.PrincipalOutput[.repo] / Unidoc.PackageMetadata[.repo]
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
                        Unidoc.PrincipalOutput[.vertex] / Unidoc.AnyVertex[.symbol],
                        BSON.Max.init()
                    )
                }
                $0[let: hash] = .expr
                {
                    $0[.coalesce] =
                    (
                        Unidoc.PrincipalOutput[.vertex] / Unidoc.AnyVertex[.hash],
                        BSON.Max.init()
                    )
                }
                //  ``volumeOfLatest`` is always non-nil, so we don’t need to worry about
                //  degenerate index behavior.
                $0[let: min] =
                    Unidoc.PrincipalOutput[.volumeOfLatest] / Unidoc.VolumeMetadata[.min]
                $0[let: max] =
                    Unidoc.PrincipalOutput[.volumeOfLatest] / Unidoc.VolumeMetadata[.max]
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
                                $0[.eq] = (Unidoc.AnyVertex[.hash], hash)
                            },
                            .expr
                            {
                                $0[.gte] = (Unidoc.AnyVertex[.id], min)
                            },
                            .expr
                            {
                                $0[.lte] = (Unidoc.AnyVertex[.id], max)
                            },

                            .expr
                            {
                                $0[.eq] = (Unidoc.AnyVertex[.symbol], symbol)
                            }
                        )
                    }
                }

                $0[.limit] = 1

                //  We do not need to load *any* markdown for this record.
                $0[.unset] =
                [
                    Unidoc.AnyVertex[.requirements],
                    Unidoc.AnyVertex[.superforms],
                    Unidoc.AnyVertex[.overview],
                    Unidoc.AnyVertex[.details],
                ]
            }
            $0[.as] = Unidoc.PrincipalOutput[.vertexInLatest]
        }
        //  Unbox single-element array.
        pipeline[.set] = .init
        {
            $0[Unidoc.PrincipalOutput[.vertexInLatest]] = .expr
            {
                $0[.first] = Unidoc.PrincipalOutput[.vertexInLatest]
            }
        }

        //  Gather all the extensions to the principal vertex.
        Context.groups(&pipeline,
            volume: Unidoc.PrincipalOutput[.volume],
            vertex: Unidoc.PrincipalOutput[.vertex],
            output: Unidoc.PrincipalOutput[.groups])

        //  Extract (and de-duplicate) the scalars and volumes mentioned by the extensions.
        //  The extensions have precomputed volume ids for MongoDB’s convenience.
        let edges:(scalars:Mongo.KeyPath, volumes:Mongo.KeyPath) = ("scalars", "volumes")

        Context.edges(&pipeline,
            volume: Unidoc.PrincipalOutput[.volume],
            vertex: Unidoc.PrincipalOutput[.vertex],
            groups: Unidoc.PrincipalOutput[.groups],
            output: edges)

        //  The `$facet` stage in ``pipeline`` should collect all records into a
        //  single document, so this pipeline should return at most 1 element.
        pipeline[.facet] = .init
        {
            $0[Unidoc.VertexOutput[.principal]] = .init
            {
                $0[.project] = .init
                {
                    for key:Unidoc.PrincipalOutput.CodingKey in
                    [
                        .matches,
                        .vertex,
                        .vertexInLatest,
                        .groups,
                        .repo,
                    ]
                    {
                        $0[Unidoc.PrincipalOutput[key]] = true
                    }
                    for volume:Unidoc.PrincipalOutput.CodingKey in
                    [
                        .volume,
                        .volumeOfLatest,
                    ]
                    {
                        //  Do not return computed fields.
                        for key:Unidoc.VolumeMetadata.CodingKey in
                        [
                            .id,
                            .dependencies,
                            .package,
                            .version,
                            .display,
                            .refname,
                            .patch,

                            //  TODO: we only need this for top-level queries and
                            //  foreign vertices!
                            .products,
                            .cultures,

                            .latest,
                            .realm,
                            .abi
                        ]
                        {
                            $0[Unidoc.PrincipalOutput[volume] / Unidoc.VolumeMetadata[key]] =
                                true
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
                            //  ``Unidoc.CultureVertex`` doesn’t have a `culture`
                            //  field, but we still want to get the type tree for
                            //  its `_id`. The ``Database.Trees`` collection only
                            //  contains type trees, so it’s okay if the `_id` is
                            //  not a culture.
                            $0[.coalesce] =
                            (
                                Unidoc.PrincipalOutput[.vertex] / Unidoc.AnyVertex[.culture],
                                Unidoc.PrincipalOutput[.vertex] / Unidoc.AnyVertex[.id],
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
                                $0[.eq] = (Unidoc.TypeTree[.id], tree)
                            }
                        }
                    }
                    $0[.as] = Unidoc.PrincipalOutput[.tree]
                }
                //  Unbox single-element array.
                $0[.set] = .init
                {
                    $0[Unidoc.PrincipalOutput[.tree]] = .expr
                    {
                        $0[.first] = Unidoc.PrincipalOutput[.tree]
                    }
                }
            }

            $0[Unidoc.VertexOutput[.vertices]] = .init
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
                    $0[.foreignField] = Unidoc.AnyVertex[.id]
                    $0[.as] = results
                }
                $0[.unwind] = results
                $0[.replaceWith] = results
                //  We do not need to load all the markdown for secondary vertices.
                $0[.unset] =
                [
                    Unidoc.AnyVertex[.requirements],
                    Unidoc.AnyVertex[.superforms],
                    Unidoc.AnyVertex[.details],
                ]
            }

            $0[Unidoc.VertexOutput[.volumes]] = .init
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
                                $0[.ne] =
                                    Unidoc.PrincipalOutput[.volume] / Unidoc.VolumeMetadata[.id]
                            }
                        }
                    }
                }
                $0[.lookup] = .init
                {
                    $0[.from] = UnidocDatabase.Volumes.name
                    $0[.localField] = edges.volumes
                    $0[.foreignField] = Unidoc.VolumeMetadata[.id]
                    $0[.as] = results
                }
                $0[.unwind] = results
                $0[.replaceWith] = results
                $0[.project] = .init(with: Unidoc.VolumeMetadata.names(_:))
            }
        }
        //  Unbox single-element arrays.
        pipeline[.set] = .init
        {
            $0[Unidoc.VertexOutput[.principal]] = .expr
            {
                $0[.first] = Unidoc.VertexOutput[.principal]
            }
        }
    }
}
