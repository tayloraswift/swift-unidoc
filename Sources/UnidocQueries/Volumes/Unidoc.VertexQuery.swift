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
    @frozen public
    struct VertexQuery<Context>:Sendable where Context:Unidoc.LookupContext & Sendable
    {
        public
        let volume:VolumeSelector
        public
        let vertex:Shoot
        public
        let lookup:Context
        public
        let unset:[Mongo.AnyKeyPath]

        @inlinable
        init(volume:VolumeSelector, vertex:Shoot, lookup:Context, unset:[Mongo.AnyKeyPath] = [])
        {
            self.volume = volume
            self.vertex = vertex
            self.lookup = lookup
            self.unset = unset
        }
    }
}
extension Unidoc.VertexQuery<Unidoc.LookupLimited>
{
    @inlinable public
    init(volume:Unidoc.VolumeSelector, vertex:Unidoc.Shoot)
    {
        self.init(volume: volume, vertex: vertex, lookup: .limited)
    }
}
extension Unidoc.VertexQuery<Unidoc.LookupAdjacent>
{
    @inlinable public
    init(volume:Unidoc.VolumeSelector, vertex:Unidoc.Shoot, layer:Unidoc.GroupLayer? = nil)
    {
        let context:Context = .init(layer: layer)
        let unset:[Unidoc.AnyVertex.CodingKey]

        switch layer
        {
        case nil:           unset = []
        case .protocols?:   unset = [.constituents, .superforms, .overview, .details]
        }

        self.init(
            volume: volume,
            vertex: vertex,
            lookup: context,
            unset: unset.map { Unidoc.AnyVertex[$0] })
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
    var volumeOfLatest:Mongo.AnyKeyPath? { Unidoc.PrincipalOutput[.volumeOfLatest] }
    @inlinable public static
    var volume:Mongo.AnyKeyPath { Unidoc.PrincipalOutput[.volume] }

    @inlinable public static
    var input:Mongo.AnyKeyPath { Unidoc.PrincipalOutput[.matches] }

    public
    func extend(pipeline:inout Mongo.PipelineEncoder)
    {
        //  Populate this field only if exactly one vertex matched.
        //  This allows us to skip looking up secondary/tertiary records if
        //  we are only going to generate a disambiguation page.
        pipeline[stage: .set] = .init
        {
            $0[Unidoc.PrincipalOutput[.vertex]] = .expr
            {
                $0[.cond] =
                (
                    if: .expr
                    {
                        $0[.eq] = (1, .expr { $0[.size] = Unidoc.PrincipalOutput[.matches] })
                    },
                    then: .expr { $0[.first] = Unidoc.PrincipalOutput[.matches] },
                    else: Never??.some(nil)
                )
            }
        }

        //  Look up the vertex in the volume of the latest stable release of its home package.
        //  The lookup correlates verticies by symbol.
        //
        //  This stage is a lot like the ``Symbol.Decl`` extension, but `symbol` and `hash`
        //  are variables obtained from the principal `vertex` record.
        pipeline[stage: .lookup] = .init
        {
            let symbol:Mongo.Variable<Unidoc.Scalar> = "symbol"
            let hash:Mongo.Variable<Unidoc.Scalar> = "hash"

            let min:Mongo.Variable<Unidoc.Scalar> = "min"
            let max:Mongo.Variable<Unidoc.Scalar> = "max"

            $0[.from] = Unidoc.DB.Vertices.name
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
                $0[stage: .match] = .init
                {
                    $0[.expr]
                    {
                        $0[.and]
                        {
                            //  The first three of these clauses should be able to use
                            //  a compound index.
                            $0.expr { $0[.eq] = (Unidoc.AnyVertex[.hash], hash) }
                            $0.expr { $0[.gte] = (Unidoc.AnyVertex[.id], min) }
                            $0.expr { $0[.lte] = (Unidoc.AnyVertex[.id], max) }

                            $0.expr { $0[.eq] = (Unidoc.AnyVertex[.symbol], symbol) }
                        }
                    }
                }

                $0[stage: .limit] = 1

                //  We do not need to load *any* markdown for this record.
                $0[stage: .unset] =
                [
                    Unidoc.AnyVertex[.constituents],
                    Unidoc.AnyVertex[.superforms],
                    Unidoc.AnyVertex[.overview],
                    Unidoc.AnyVertex[.details],
                ]
            }
            $0[.as] = Unidoc.PrincipalOutput[.vertexInLatest]
        }
        //  Unbox single-element array.
        pipeline[stage: .set] = .init
        {
            $0[Unidoc.PrincipalOutput[.vertexInLatest]] = .expr
            {
                $0[.first] = Unidoc.PrincipalOutput[.vertexInLatest]
            }
        }

        //  Gather all the extensions to the principal vertex.
        self.lookup.groups(&pipeline,
            volume: Unidoc.PrincipalOutput[.volume],
            vertex: Unidoc.PrincipalOutput[.vertex],
            output: Unidoc.PrincipalOutput[.groups])

        //  Extract (and de-duplicate) the scalars and volumes mentioned by the extensions.
        //  The extensions have precomputed volume ids for MongoDB’s convenience.
        let edges:(scalars:Mongo.AnyKeyPath, volumes:Mongo.AnyKeyPath) = ("scalars", "volumes")

        self.lookup.edges(&pipeline,
            volume: Unidoc.PrincipalOutput[.volume],
            vertex: Unidoc.PrincipalOutput[.vertex],
            groups: Unidoc.PrincipalOutput[.groups],
            output: edges)

        //  The `$facet` stage in ``pipeline`` should collect all records into a
        //  single document, so this pipeline should return at most 1 element.
        pipeline[stage: .facet] = .init
        {
            $0[Unidoc.VertexOutput[.principal]] = .init
            {
                $0[stage: .project] = .init
                {
                    for key:Unidoc.PrincipalOutput.CodingKey in
                    [
                        .matches,
                        .vertex,
                        .vertexInLatest,
                        .groups,
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
                $0[stage: .lookup] = .init
                {
                    let tree:Mongo.Variable<Unidoc.Scalar> = "tree"

                    $0[.from] = Unidoc.DB.Trees.name
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
                        $0[stage: .match] = .init
                        {
                            $0[.expr] { $0[.eq] = (Unidoc.TypeTree[.id], tree) }
                        }
                    }
                    $0[.as] = Unidoc.PrincipalOutput[.tree]
                }
                //  Unbox single-element array.
                $0[stage: .set] = .init
                {
                    $0[Unidoc.PrincipalOutput[.tree]] = .expr
                    {
                        $0[.first] = Unidoc.PrincipalOutput[.tree]
                    }
                }
            }

            $0[Unidoc.VertexOutput[.vertices]] = .init
            {
                let results:Mongo.AnyKeyPath = "results"

                $0[stage: .unwind] = edges.scalars
                $0[stage: .match] = .init
                {
                    $0[edges.scalars] { $0[.ne] = BSON.Null.init() }
                }
                $0[stage: .lookup] = .init
                {
                    $0[.from] = Unidoc.DB.Vertices.name
                    $0[.localField] = edges.scalars
                    $0[.foreignField] = Unidoc.AnyVertex[.id]
                    $0[.as] = results
                }
                $0[stage: .unwind] = results
                $0[stage: .replaceWith] = results
                //  We do not need to load all the markdown for secondary vertices.
                $0[stage: .unset] =
                [
                    Unidoc.AnyVertex[.constituents],
                    Unidoc.AnyVertex[.superforms],
                    Unidoc.AnyVertex[.details],
                    Unidoc.AnyVertex[.census],
                ]
            }

            $0[Unidoc.VertexOutput[.volumes]] = .init
            {
                let results:Mongo.AnyKeyPath = "results"

                $0[stage: .unwind] = edges.volumes
                $0[stage: .match] = .init
                {
                    $0[.and]
                    {
                        $0
                        {
                            $0[edges.volumes] { $0[.ne] = BSON.Null.init() }
                        }
                        $0
                        {
                            $0[edges.volumes]
                            {
                                $0[.ne] =
                                    Unidoc.PrincipalOutput[.volume] / Unidoc.VolumeMetadata[.id]
                            }
                        }
                    }
                }
                $0[stage: .lookup] = .init
                {
                    $0[.from] = Unidoc.DB.Volumes.name
                    $0[.localField] = edges.volumes
                    $0[.foreignField] = Unidoc.VolumeMetadata[.id]
                    $0[.as] = results
                }
                $0[stage: .unwind] = results
                $0[stage: .replaceWith] = results
                $0[stage: .project] = .init(with: Unidoc.VolumeMetadata.names(_:))
            }

            //  This really does need to be written with two unwinds, a naïve `$in` lookup
            //  causes a collection scan for some reason.
            $0[Unidoc.VertexOutput[.packages]] = .init
            {
                let id:Mongo.AnyKeyPath = "_id"

                self.lookup.packages(&$0,
                    volume: Unidoc.PrincipalOutput[.volume],
                    vertex: Unidoc.PrincipalOutput[.vertex],
                    output: id)

                $0[stage: .unwind] = id
                $0[stage: .lookup] = .init
                {
                    $0[.from] = Unidoc.DB.Packages.name
                    $0[.localField] = id
                    $0[.foreignField] = Unidoc.PackageMetadata[.id]
                    $0[.as] = id
                }
                $0[stage: .unwind] = id
                $0[stage: .replaceWith] = id
            }
        }

        //  Unbox single-element arrays.
        pipeline[stage: .set] = .init
        {
            $0[Unidoc.VertexOutput[.principal]] = .expr
            {
                $0[.first] = Unidoc.VertexOutput[.principal]
            }
        }
    }
}
