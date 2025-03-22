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
        let vertex:VertexPath
        public
        let lookup:Context
        @usableFromInline
        let fields:VertexProjection

        @inlinable
        init(volume:VolumeSelector, vertex:VertexPath, lookup:Context, fields:VertexProjection)
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
    init(volume:Unidoc.VolumeSelector, vertex:Unidoc.VertexPath)
    {
        //  We use this for stats, so we need the census data!
        //  TODO: define a more-efficient projection for stats.
        self.init(volume: volume, vertex: vertex, lookup: .limited, fields: .all)
    }
}
extension Unidoc.VertexQuery<Unidoc.LookupAdjacent>
{
    @inlinable public
    init(volume:Unidoc.VolumeSelector, vertex:Unidoc.VertexPath, layer:Unidoc.GroupLayer? = nil)
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
extension Unidoc.VertexQuery
{
    private
    enum FacetOne:Mongo.MasterCodingModel
    {
        enum CodingKey:String
        {
            case principalOnly
            case carryover
        }
    }

    private
    enum FacetTwo:Mongo.MasterCodingModel
    {
        enum CodingKey:String
        {
            case lookupCanonical
            case lookupGridCell

            case lookupPackages
            case lookupVertices
            case lookupVolumes
            case carryover
        }
    }
}
extension Unidoc.VertexQuery:Mongo.PipelineQuery
{
    public
    typealias Iteration = Mongo.Single<Unidoc.VertexOutput>

    @inlinable public
    var collation:Mongo.Collation { .casefolding }
    @inlinable public
    var from:Mongo.Collection? { Unidoc.DB.Volumes.name }
    @inlinable public
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
            pipeline[stage: .replaceWith, using: Output.CodingKey.self]
            {
                $0[.principalVolume] = Mongo.Pipeline.ROOT
            }

            pipeline[stage: .lookup]
            {
                $0[.from] = Unidoc.DB.Volumes.name
                $0[.pipeline] { $0.volume(package: self.volume.package) }
                $0[.as] = Output[.canonicalVolume]
            }

            //  Unbox the single-element array.
            pipeline[stage: .set, using: Output.CodingKey.self]
            {
                $0[.canonicalVolume] { $0[.first] = Output[.canonicalVolume] }
            }
        }
        else
        {
            //  Match the latest volume, and duplicate the output into the `volume` and
            //  `volumeOfLatest` fields. ``Unidoc.VolumeMetadata`` is complex but not that
            //  large, and duplicating this makes the rest of the query a lot simpler.
            pipeline.volume(package: self.volume.package)

            pipeline[stage: .replaceWith, using: Output.CodingKey.self]
            {
                $0[.principalVolume] = Mongo.Pipeline.ROOT
                $0[.canonicalVolume] = Mongo.Pipeline.ROOT
            }
        }

        pipeline.lookup(vertex: self.vertex,
            volume: Output[.principalVolume],
            output: Output[.matches],
            fields: self.fields)

        //  Populate this field only if exactly one vertex matched.
        //  This allows us to skip looking up secondary/tertiary records if
        //  we are only going to generate a disambiguation page.
        pipeline[stage: .set, using: Output.CodingKey.self]
        {
            $0[.principalVertex]
            {
                $0[.cond]
                {
                    $0[.if]
                    {
                        $0[.eq] = (1, .expr { $0[.size] = Output[.matches] })
                    }
                    $0[.then] = Output[.matches]
                    $0[.else] = BSON.Null.init()
                }
            }
        }

        pipeline[stage: .facet, using: FacetOne.CodingKey.self] { self.build(facet: &$0) }
        //  We need this because `$facet` injects a document even if the pipeline didn’t match
        //  a principal volume.
        pipeline[stage: .unwind] = FacetTwo[.carryover]
        pipeline[stage: .set, using: FacetOne.CodingKey.self]
        {
            $0[.principalOnly] { $0[.first] = FacetOne[.principalOnly] }
        }
        pipeline[stage: .replaceWith]
        {
            $0[.mergeObjects]
            {
                //  Carried-over fields come second, because we want to keep the cleaned-up
                //  volume metadata documents instead of the raw ones.
                $0[+] = FacetOne[.principalOnly]
                $0[+] = FacetTwo[.carryover]
            }
        }

        pipeline[stage: .facet, using: FacetTwo.CodingKey.self] { self.build(facet: &$0) }
        pipeline[stage: .unwind] = FacetTwo[.carryover]
        pipeline[stage: .set, using: FacetTwo.CodingKey.self]
        {
            $0[.lookupCanonical] { $0[.first] = FacetTwo[.lookupCanonical] }
            $0[.lookupGridCell] { $0[.first] = FacetTwo[.lookupGridCell] }
        }

        pipeline[stage: .replaceWith]
        {
            $0[.mergeObjects]
            {
                $0[+] = FacetTwo[.carryover]
                $0(Output.CodingKey.self)
                {
                    $0[.adjacentPackages] = FacetTwo[.lookupPackages]
                    $0[.adjacentVertices] = FacetTwo[.lookupVertices]
                    $0[.adjacentVolumes] = FacetTwo[.lookupVolumes]
                    $0[.canonicalVertex] = FacetTwo[.lookupCanonical]
                }
            }
        }
    }

    private
    func build(facet:inout Mongo.FacetEncoder<FacetOne.CodingKey>)
    {
        facet[.principalOnly]
        {
            //  Exit early if there is no principal vertex.
            $0[stage: .unwind] = Output[.principalVertex]

            self.lookup.packages(&$0,
                volume: Output[.principalVolume],
                vertex: Output[.principalVertex],
                output: Output[.adjacentPackages])

            //  Gather all the extensions to the principal vertex.
            self.lookup.groups(&$0,
                volume: Output[.principalVolume],
                vertex: Output[.principalVertex],
                output: Output[.principalGroups])

            //  Extract (and de-duplicate) the scalars and volumes mentioned by the
            //  extensions. The extensions have precomputed volume ids for MongoDB’s
            //  convenience.
            self.lookup.edges(&$0,
                volume: Output[.principalVolume],
                vertex: Output[.principalVertex],
                groups: Output[.principalGroups],
                output: (Output[.adjacentVertices], volumes: Output[.adjacentVolumes]))

            $0[stage: .set, using: Output.CodingKey.self]
            {
                $0[.tree]
                {
                    //  ``Unidoc.CultureVertex`` doesn’t have a `culture`
                    //  field, but we still want to get the type tree for
                    //  its `_id`. The ``Database.Trees`` collection only
                    //  contains type trees, so it’s okay if the `_id` is
                    //  not a culture.
                    $0[.coalesce] =
                    (
                        Output[.principalVertex] / Unidoc.AnyVertex[.culture],
                        Output[.principalVertex] / Unidoc.AnyVertex[.id],
                        BSON.Max.init()
                    )
                }
            }
            $0[stage: .lookup]
            {
                $0[.from] = Unidoc.DB.Trees.name
                $0[.localField] = Output[.tree]
                $0[.foreignField] = Unidoc.TypeTree[.id]
                $0[.as] = Output[.tree]
            }
            //  Unbox optional single-element array.
            $0[stage: .set, using: Output.CodingKey.self]
            {
                $0[.tree] { $0[.first] = Output[.tree] }
            }
        }

        facet[.carryover]
        {
            $0[stage: .project, using: Output.CodingKey.self]
            {
                $0[.matches] = true
                //  Right now, we still need these in order to fully utilize the index
                //  on the vertex collection.
                $0[.principalVolume] = true // Unidoc.VolumeMetadata.StoredFields.init()
                $0[.canonicalVolume] = true // Unidoc.VolumeMetadata.StoredFields.init()
            }
        }
    }

    private
    func build(facet:inout Mongo.FacetEncoder<FacetTwo.CodingKey>)
    {
        //  These facets really do need to be written with two unwinds, a naïve `$in` lookup
        //  causes a collection scan for some reason.
        facet[.lookupPackages]
        {
            $0[stage: .unwind] = Output[.adjacentPackages]
            $0[stage: .lookup]
            {
                $0[.from] = Unidoc.DB.Packages.name
                $0[.localField] = Output[.adjacentPackages]
                $0[.foreignField] = Unidoc.PackageMetadata[.id]
                $0[.as] = Output[.adjacentPackages]
            }
            $0[stage: .unwind] = Output[.adjacentPackages]
            $0[stage: .replaceWith] = Output[.adjacentPackages]
        }

        facet[.lookupVertices]
        {
            $0[stage: .unwind] = Output[.adjacentVertices]
            $0[stage: .match]
            {
                $0[Output[.adjacentVertices]] { $0[.ne] = BSON.Null.init() }
            }
            $0[stage: .lookup]
            {
                $0[.from] = Unidoc.DB.Vertices.name
                $0[.localField] = Output[.adjacentVertices]
                $0[.foreignField] = Unidoc.AnyVertex[.id]
                $0[.pipeline]
                {
                    //  We do not need to load all the markdown for adjacent vertices.
                    $0[stage: .unset] =
                    [
                        Unidoc.AnyVertex[.constituents],
                        Unidoc.AnyVertex[.superforms],
                        Unidoc.AnyVertex[.details],
                        Unidoc.AnyVertex[.census],
                    ]
                }
                $0[.as] = Output[.adjacentVertices]
            }
            $0[stage: .unwind] = Output[.adjacentVertices]
            $0[stage: .replaceWith] = Output[.adjacentVertices]
        }

        facet[.lookupVolumes]
        {
            $0[stage: .unwind] = Output[.adjacentVolumes]
            $0[stage: .match]
            {
                $0[Output[.adjacentVolumes]] { $0[.ne] = BSON.Null.init() }
            }
            $0[stage: .match]
            {
                $0[.expr]
                {
                    $0[.ne] =
                    (
                        Output[.adjacentVolumes],
                        Output[.principalVolume] / Unidoc.VolumeMetadata[.id]
                    )
                }
            }
            $0[stage: .lookup]
            {
                $0[.from] = Unidoc.DB.Volumes.name
                $0[.localField] = Output[.adjacentVolumes]
                $0[.foreignField] = Unidoc.VolumeMetadata[.id]
                $0[.pipeline]
                {
                    $0[stage: .project] = Unidoc.VolumeMetadata.NameFields.init()
                }
                $0[.as] = Output[.adjacentVolumes]
            }
            $0[stage: .unwind] = Output[.adjacentVolumes]
            $0[stage: .replaceWith] = Output[.adjacentVolumes]
        }

        //  This keeps turning into a collection scan for some reason.
        #if false
        if  Context.lookupGridCell
        {
            facet[.lookupGridCell]
            {
                $0[stage: .unwind] = Output[.principalVertex]
                $0[stage: .lookup]
                {
                    let trunk:Mongo.Variable<Unidoc.Edition> = "trunk"
                    let stem:Mongo.Variable<Unidoc.Stem> = "stem"
                    let hash:Mongo.Variable<Int32?> = "hash"

                    $0[.from] = Unidoc.DB.SearchbotGrid.name
                    $0[.let]
                    {
                        $0[let: trunk] = Output[.principalVolume] / Unidoc.VolumeMetadata[.cell]
                        $0[let: stem] = Output[.principalVertex] / Unidoc.AnyVertex[.stem]
                        $0[let: hash]
                        {
                            $0[.cond]
                            {
                                $0[.if]
                                {
                                    $0[.eq] =
                                    (
                                        1,
                                        .expr
                                        {
                                            $0[.bitAnd] =
                                            (
                                                Output[.principalVertex] / Unidoc.AnyVertex[.flags],
                                                1
                                            )
                                        }
                                    )
                                }
                                $0[.then]
                                {
                                    $0[.divide] =
                                    (
                                        Output[.principalVertex] / Unidoc.AnyVertex[.hash],
                                        by: 256
                                    )
                                }
                                $0[.else] = BSON.Null.init()
                            }
                        }
                    }
                    $0[.pipeline]
                    {
                        $0[stage: .match]
                        {
                            $0[.expr]
                            {
                                $0[.and]
                                {
                                    $0
                                    {
                                        $0[.eq] =
                                        (
                                            Unidoc.SearchbotCell[.id] / Unidoc.SearchbotCell.ID[.trunk],
                                            trunk
                                        )
                                    }
                                    $0
                                    {
                                        $0[.eq] =
                                        (
                                            Unidoc.SearchbotCell[.id] / Unidoc.SearchbotCell.ID[.stem],
                                            stem
                                        )
                                    }
                                    $0
                                    {
                                        $0[.eq] =
                                        (
                                            Unidoc.SearchbotCell[.id] / Unidoc.SearchbotCell.ID[.hash],
                                            hash
                                        )
                                    }
                                }
                            }
                        }
                        $0[stage: .limit] = 1
                    }
                    $0[.as] = Output[.coverage]
                }
            }
        }
        #endif

        facet[.lookupCanonical]
        {
            //  Exit early if there is no principal vertex, or no canonical volume.
            //
            //  We need to skip ahead if either field is null because otherwise
            //  the lookups in the next stage will traverse *all* vertices with the same
            //  hash, which has complexity that scales with the number of linked volumes.
            $0[stage: .unwind] = Output[.principalVertex]
            $0[stage: .unwind] = Output[.canonicalVolume]

            //  Look up the vertex in the volume of the latest stable release of its home
            //  package. The lookup correlates vertices by symbol.
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
                            Output[.principalVertex] / Unidoc.AnyVertex[.symbol],
                            BSON.Max.init()
                        )
                    }
                    $0[let: hash]
                    {
                        $0[.coalesce] =
                        (
                            Output[.principalVertex] / Unidoc.AnyVertex[.hash],
                            BSON.Max.init()
                        )
                    }

                    $0[let: min] = Output[.canonicalVolume] / Unidoc.VolumeMetadata[.min]
                    $0[let: max] = Output[.canonicalVolume] / Unidoc.VolumeMetadata[.max]
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
                                $0 { $0[.eq] = (Unidoc.AnyVertex[.hash], hash) }
                                $0 { $0[.gte] = (Unidoc.AnyVertex[.id], min) }
                                $0 { $0[.lte] = (Unidoc.AnyVertex[.id], max) }

                                $0 { $0[.eq] = (Unidoc.AnyVertex[.symbol], symbol) }
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
                $0[.as] = Output[.canonicalVertex]
            }
            $0[stage: .unwind] = Output[.canonicalVertex]
            $0[stage: .replaceWith] = Output[.canonicalVertex]
        }

        facet[.carryover]
    }
}
