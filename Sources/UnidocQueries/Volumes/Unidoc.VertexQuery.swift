import BSON
import MongoDB
import MongoQL
import Unidoc
import UnidocAPI
import UnidocDB
import UnidocRecords

extension Unidoc
{
    /// Performs a vertex query within a volume, with additional lookups as determined by
    /// the specialized `Context`.
    @frozen public
    struct VertexQuery<Context>:Sendable where Context:LookupContext & Sendable
    {
        public
        let volume:VolumeSelector
        public
        let vertex:Shoot
        public
        let lookup:Context
        @usableFromInline
        let fields:VertexProjection

        @inlinable
        init(volume:VolumeSelector, vertex:Shoot, lookup:Context, fields:VertexProjection)
        {
            self.volume = volume
            self.vertex = vertex
            self.lookup = lookup
            self.fields = fields
        }
    }
}
extension Unidoc.VertexQuery<Unidoc.LookupLimited>
{
    @inlinable public
    init(volume:Unidoc.VolumeSelector, vertex:Unidoc.Shoot)
    {
        //  We use this for stats, so we need the census data!
        //  TODO: define a more-efficient projection for stats.
        self.init(volume: volume, vertex: vertex, lookup: .limited, fields: .all)
    }
}
extension Unidoc.VertexQuery<Unidoc.LookupAdjacent>
{
    @inlinable public
    init(volume:Unidoc.VolumeSelector, vertex:Unidoc.Shoot, layer:Unidoc.GroupLayer? = nil)
    {
        let context:Context = .init(layer: layer)
        let fields:Unidoc.VertexProjection

        switch layer
        {
        case nil:           fields = .all
        case .protocols?:   fields = .limited
        }

        self.init(volume: volume, vertex: vertex, lookup: context, fields: fields)
    }
}
extension Unidoc.VertexQuery:Mongo.PipelineQuery
{
    public
    typealias CollectionOrigin = Unidoc.DB.Volumes
    public
    typealias Collation = VolumeCollation
    public
    typealias Iteration = Mongo.Single<Unidoc.VertexOutput>

    public
    var hint:Mongo.CollectionIndex?
    {
        self.volume.version == nil
            ? Unidoc.DB.Volumes.indexSymbolicPatch
            : Unidoc.DB.Volumes.indexSymbolic
    }

    public
    func build(pipeline:inout Mongo.PipelineEncoder)
    {
        if  let version:Substring = self.volume.version
        {
            //  If a version string was provided, use that to filter between
            //  multiple versions of the same package.
            pipeline.volume(package: self.volume.package, version: version)

            //  ``Unidoc.VolumeMetadata`` has many keys. to simplify the output schema
            //  and allow re-use of the earlier pipeline stages, we demote
            //  the zone fields to a subdocument.
            pipeline[stage: .replaceWith, using: Unidoc.PrincipalOutput.CodingKey.self]
            {
                $0[.volume] = Mongo.Pipeline.ROOT
            }

            let volumeOfLatest:Mongo.AnyKeyPath = Unidoc.PrincipalOutput[.volumeOfLatest]

            pipeline[stage: .lookup]
            {
                $0[.from] = Unidoc.DB.Volumes.name
                $0[.pipeline] { $0.volume(package: self.volume.package) }
                $0[.as] = volumeOfLatest
            }

            //  Unbox the single-element array.
            pipeline[stage: .set] { $0[volumeOfLatest] { $0[.first] = volumeOfLatest } }
        }
        else
        {
            //  Match the latest volume, and duplicate the output into the `volume` and
            //  `volumeOfLatest` fields. ``Unidoc.VolumeMetadata`` is complex but not that
            //  large, and duplicating this makes the rest of the query a lot simpler.
            pipeline.volume(package: self.volume.package)

            pipeline[stage: .replaceWith, using: Unidoc.PrincipalOutput.CodingKey.self]
            {
                $0[.volume] = Mongo.Pipeline.ROOT
                $0[.volumeOfLatest] = Mongo.Pipeline.ROOT
            }
        }

        pipeline.lookup(vertex: self.vertex,
            volume: Unidoc.PrincipalOutput[.volume],
            output: Unidoc.PrincipalOutput[.matches],
            fields: self.fields)

        //  Populate this field only if exactly one vertex matched.
        //  This allows us to skip looking up secondary/tertiary records if
        //  we are only going to generate a disambiguation page.
        pipeline[stage: .set, using: Unidoc.PrincipalOutput.CodingKey.self]
        {
            $0[.vertex]
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
        pipeline[stage: .facet, using: Unidoc.VertexOutput.CodingKey.self]
        {
            $0[.principal]
            {
                $0[stage: .project, using: Unidoc.PrincipalOutput.CodingKey.self]
                {
                    $0[.matches] = true
                    $0[.vertex] = true
                    $0[.groups] = true

                    $0[.volume] = Unidoc.VolumeMetadata.StoredFields.init()
                    $0[.volumeOfLatest] = Unidoc.VolumeMetadata.StoredFields.init()
                }
                $0[stage: .lookup]
                {
                    let tree:Mongo.Variable<Unidoc.Scalar> = "tree"

                    $0[.from] = Unidoc.DB.Trees.name
                    $0[.let]
                    {
                        $0[let: tree]
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
                    $0[.pipeline]
                    {
                        $0[stage: .match]
                        {
                            $0[.expr] { $0[.eq] = (Unidoc.TypeTree[.id], tree) }
                        }
                    }
                    $0[.as] = Unidoc.PrincipalOutput[.tree]
                }
                //  Unbox single-element array.
                $0[stage: .set, using: Unidoc.PrincipalOutput.CodingKey.self]
                {
                    $0[.tree] { $0[.first] = Unidoc.PrincipalOutput[.tree] }
                }
            }

            $0[.canonical]
            {
                let volume:Mongo.AnyKeyPath = Unidoc.PrincipalOutput[.volumeOfLatest]
                //  Conveniently, `$unwind` can be used to skip null values even if the field
                //  is not an array. We need to skip the field if it is null because otherwise
                //  the lookups in the next stage will traverse *all* vertices with the same
                //  hash, which has complexity that scales with the number of linked volumes.
                $0[stage: .unwind] = volume

                //  Look up the vertex in the volume of the latest stable release of its home
                //  package. The lookup correlates verticies by symbol.
                $0[stage: .lookup]
                {
                    let symbol:Mongo.Variable<Unidoc.Scalar> = "symbol"
                    let hash:Mongo.Variable<Unidoc.Scalar> = "hash"

                    let min:Mongo.Variable<Unidoc.Scalar> = "min"
                    let max:Mongo.Variable<Unidoc.Scalar> = "max"

                    $0[.from] = Unidoc.DB.Vertices.name
                    $0[.let]
                    {
                        $0[let: symbol]
                        {
                            $0[.coalesce] =
                            (
                                Unidoc.PrincipalOutput[.vertex] / Unidoc.AnyVertex[.symbol],
                                BSON.Max.init()
                            )
                        }
                        $0[let: hash]
                        {
                            $0[.coalesce] =
                            (
                                Unidoc.PrincipalOutput[.vertex] / Unidoc.AnyVertex[.hash],
                                BSON.Max.init()
                            )
                        }

                        $0[let: min] = volume / Unidoc.VolumeMetadata[.min]
                        $0[let: max] = volume / Unidoc.VolumeMetadata[.max]
                    }
                    $0[.pipeline]
                    {
                        $0[stage: .match]
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
                    $0[.as] = Unidoc.PrincipalOutput[.vertex]
                }
                //  Unbox single-element array.
                $0[stage: .unwind] = Unidoc.PrincipalOutput[.vertex]
                $0[stage: .replaceWith] = Unidoc.PrincipalOutput[.vertex]
            }

            $0[.vertices]
            {
                let results:Mongo.AnyKeyPath = "results"

                $0[stage: .unwind] = edges.scalars
                $0[stage: .match]
                {
                    $0[edges.scalars] { $0[.ne] = BSON.Null.init() }
                }
                $0[stage: .lookup]
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

            $0[.volumes]
            {
                let results:Mongo.AnyKeyPath = "results"

                $0[stage: .unwind] = edges.volumes
                $0[stage: .match]
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
                $0[stage: .lookup]
                {
                    $0[.from] = Unidoc.DB.Volumes.name
                    $0[.localField] = edges.volumes
                    $0[.foreignField] = Unidoc.VolumeMetadata[.id]
                    $0[.as] = results
                }
                $0[stage: .unwind] = results
                $0[stage: .replaceWith] = results
                $0[stage: .project] = Unidoc.VolumeMetadata.NameFields.init()
            }

            //  This really does need to be written with two unwinds, a naïve `$in` lookup
            //  causes a collection scan for some reason.
            $0[.packages]
            {
                let id:Mongo.AnyKeyPath = "_id"

                self.lookup.packages(&$0,
                    volume: Unidoc.PrincipalOutput[.volume],
                    vertex: Unidoc.PrincipalOutput[.vertex],
                    output: id)

                $0[stage: .unwind] = id
                $0[stage: .lookup]
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

        //  Unwind the principal vertex, without which the pipeline would not yield a
        //  meaningful result.
        pipeline[stage: .unwind] = Unidoc.VertexOutput[.principal]

        //  Unbox single-element optional array.
        pipeline[stage: .set, using: Unidoc.VertexOutput.CodingKey.self]
        {
            $0[.canonical] { $0[.first] = Unidoc.VertexOutput[.canonical] }
        }
    }
}
