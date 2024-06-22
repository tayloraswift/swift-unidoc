
import MongoQL
import UnidocDB
import UnidocRecords

extension Unidoc
{
    public
    protocol VolumeQuery:Mongo.PipelineQuery<DB.Volumes> where Collation == VolumeCollation
    {
        associatedtype VertexPredicate:Unidoc.VertexPredicate

        var volume:VolumeSelector { get }
        var vertex:VertexPredicate { get }

        /// The field to store the ``VolumeMetadata`` of the **latest stable release**
        /// (relative to the current volume) in.
        ///
        /// If nil, the query will still look up the latest stable release, but the result will
        /// be discarded.
        static
        var volumeOfLatest:Mongo.AnyKeyPath? { get }
        /// The field to store the ``VolumeMetadata`` of the **requested snapshot** in.
        static
        var volume:Mongo.AnyKeyPath { get }

        /// The field that will contain the list of matching master records, which will become
        /// the input of the conforming type’s ``extend(pipeline:)`` witness.
        static
        var input:Mongo.AnyKeyPath { get }

        /// The fields that will be removed from all matching primary vertex documents.
        var unset:[Mongo.AnyKeyPath] { get }

        func extend(pipeline:inout Mongo.PipelineEncoder)
    }
}
extension Unidoc.VolumeQuery
{
    @inlinable public static
    var volumeOfLatest:Mongo.AnyKeyPath? { nil }
}
extension Unidoc.VolumeQuery
{
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
        defer
        {
            self.vertex.extend(pipeline: &pipeline,
                volume: Self.volume,
                output: Self.input,
                unset: self.unset)

            self.extend(pipeline: &pipeline)
        }

        switch self.volume.version
        {
        case nil:
            //  Look up the volume with the highest semantic version. Unstable and prerelease
            //  versions are not eligible.
            //
            //  This works a lot like ``Database.Names.latest(of:with:)``, except it queries the
            //  package by name instead of id.
            pipeline[stage: .match]
            {
                $0[Unidoc.VolumeMetadata[.package]] = self.volume.package
                $0[Unidoc.VolumeMetadata[.patch]] { $0[.exists] = true }
            }
            //  We use the patch number instead of the latest-flag because
            //  it is closer to the ground-truth, and the latest-flag doesn’t
            //  have a unique (compound) index with the package name, since
            //  it experiences rolling alignments.
            pipeline[stage: .sort] = .init
            {
                $0[Unidoc.VolumeMetadata[.patch]] = (-)
            }

            pipeline[stage: .limit] = 1

            pipeline[stage: .replaceWith] = .init
            {
                $0[Self.volume] = Mongo.Pipeline.ROOT

                //  ``Unidoc.VolumeMetadata`` is complex but not that large, and duplicating this
                //  makes the rest of the query a lot simpler.
                if  let volume:Mongo.AnyKeyPath = Self.volumeOfLatest
                {
                    $0[volume] = Mongo.Pipeline.ROOT
                }
            }

        case let version?:
            //  If a version string was provided, use that to filter between
            //  multiple versions of the same package.
            //  This index is unique, so we don’t need a sort or a limit.
            pipeline[stage: .match]
            {
                $0[Unidoc.VolumeMetadata[.package]] = self.volume.package
                $0[Unidoc.VolumeMetadata[.version]] = version
            }
            //  ``Unidoc.VolumeMetadata`` has many keys. to simplify the output schema
            //  and allow re-use of the earlier pipeline stages, we demote
            //  the zone fields to a subdocument.
            pipeline[stage: .replaceWith] = .init
            {
                $0[Self.volume] = Mongo.Pipeline.ROOT
            }

            guard
            let volumeOfLatest:Mongo.AnyKeyPath = Self.volumeOfLatest
            else
            {
                break
            }

            pipeline[stage: .lookup]
            {
                $0[.from] = CollectionOrigin.name
                $0[.pipeline]
                {
                    $0[stage: .match]
                    {
                        $0[Unidoc.VolumeMetadata[.package]] = self.volume.package
                        $0[Unidoc.VolumeMetadata[.patch]] { $0[.exists] = true }
                    }
                    $0[stage: .sort] = .init
                    {
                        $0[Unidoc.VolumeMetadata[.patch]] = (-)
                    }

                    $0[stage: .limit] = 1
                }
                $0[.as] = volumeOfLatest
            }

            //  Unbox the single-element array.
            pipeline[stage: .set] { $0[volumeOfLatest] { $0[.first] = volumeOfLatest } }
        }
    }
}
