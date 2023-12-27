
import MongoQL
import UnidocDB
import UnidocRecords

extension Unidoc
{
    public
    typealias VolumeQuery = _UnidocVolumeQuery
}

/// The name of this protocol is ``Unidoc.VolumeQuery``.
public
protocol _UnidocVolumeQuery:Mongo.PipelineQuery<UnidocDatabase.Volumes>
    where Collation == VolumeCollation
{
    associatedtype VertexPredicate:Unidoc.VertexPredicate

    var volume:Unidoc.VolumeSelector { get }
    var vertex:VertexPredicate { get }

    /// The field to store the ``Unidoc.VolumeMetadata`` of the **latest stable release**
    /// (relative to the current volume) in.
    ///
    /// If nil, the query will still look up the latest stable release, but the result will
    /// be discarded.
    static
    var volumeOfLatest:Mongo.KeyPath? { get }
    /// The field to store the ``Unidoc.VolumeMetadata`` of the **requested snapshot** in.
    static
    var volume:Mongo.KeyPath { get }

    /// The field that will contain the list of matching master records, which will become the
    /// input of the conforming type’s ``extend(pipeline:)`` witness.
    static
    var input:Mongo.KeyPath { get }

    func extend(pipeline:inout Mongo.PipelineEncoder)
}
extension Unidoc.VolumeQuery
{
    @inlinable public static
    var volumeOfLatest:Mongo.KeyPath? { nil }
}
extension Unidoc.VolumeQuery
{
    public
    var hint:Mongo.CollectionIndex?
    {
        self.volume.version == nil
            ? UnidocDatabase.Volumes.indexSymbolicPatch
            : UnidocDatabase.Volumes.indexSymbolic
    }

    public
    func build(pipeline:inout Mongo.PipelineEncoder)
    {
        defer
        {
            self.vertex.extend(pipeline: &pipeline, volume: Self.volume, output: Self.input)
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
            pipeline[.match] = .init
            {
                $0[Unidoc.VolumeMetadata[.package]] = self.volume.package
                $0[Unidoc.VolumeMetadata[.patch]] = .init { $0[.exists] = true }
            }
            //  We use the patch number instead of the latest-flag because
            //  it is closer to the ground-truth, and the latest-flag doesn’t
            //  have a unique (compound) index with the package name, since
            //  it experiences rolling alignments.
            pipeline[.sort] = .init
            {
                $0[Unidoc.VolumeMetadata[.patch]] = (-)
            }

            pipeline[.limit] = 1

            pipeline[.replaceWith] = .init
            {
                $0[Self.volume] = Mongo.Pipeline.ROOT

                //  ``Unidoc.VolumeMetadata`` is complex but not that large, and duplicating this
                //  makes the rest of the query a lot simpler.
                if  let volume:Mongo.KeyPath = Self.volumeOfLatest
                {
                    $0[volume] = Mongo.Pipeline.ROOT
                }
            }

        case let version?:
            //  If a version string was provided, use that to filter between
            //  multiple versions of the same package.
            //  This index is unique, so we don’t need a sort or a limit.
            pipeline[.match] = .init
            {
                $0[Unidoc.VolumeMetadata[.package]] = self.volume.package
                $0[Unidoc.VolumeMetadata[.version]] = version
            }
            //  ``Unidoc.VolumeMetadata`` has many keys. to simplify the output schema
            //  and allow re-use of the earlier pipeline stages, we demote
            //  the zone fields to a subdocument.
            pipeline[.replaceWith] = .init
            {
                $0[Self.volume] = Mongo.Pipeline.ROOT
            }

            guard
            let volumeOfLatest:Mongo.KeyPath = Self.volumeOfLatest
            else
            {
                break
            }

            pipeline[.lookup] = .init
            {
                $0[.from] = CollectionOrigin.name
                $0[.pipeline] = .init
                {
                    $0[.match] = .init
                    {
                        $0[Unidoc.VolumeMetadata[.package]] = self.volume.package
                        $0[Unidoc.VolumeMetadata[.patch]] = .init { $0[.exists] = true }
                    }
                    $0[.sort] = .init
                    {
                        $0[Unidoc.VolumeMetadata[.patch]] = (-)
                    }

                    $0[.limit] = 1
                }
                $0[.as] = volumeOfLatest
            }
            //  Unbox the single-element array. It must contain at least one element for the
            //  query to have been successful, so we can simply use an `$unwind`.
            //
            //  One of the implications of this is that it is *impossible* to access unreleased
            //  documentation if the package does not have at least one release in the database.
            pipeline[.unwind] = volumeOfLatest
        }
    }
}
