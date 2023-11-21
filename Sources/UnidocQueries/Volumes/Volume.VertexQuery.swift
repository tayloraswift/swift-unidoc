
import MongoQL
import UnidocDB
import UnidocRecords

extension Volume
{
    public
    typealias VertexQuery = _VolumeVertexQuery
}

/// The name of this protocol is ``Volume.VertexQuery``.
public
protocol _VolumeVertexQuery:DatabaseQuery where Collation == VolumeCollation
{
    associatedtype VertexPredicate:Volume.VertexPredicate

    var volume:Volume.Selector { get }
    var vertex:VertexPredicate { get }

    /// The field to store the ``Volume.Meta`` of the **latest stable release**
    /// (relative to the current volume) in.
    ///
    /// If nil, the query will still look up the latest stable release, but the result will
    /// be discarded.
    static
    var volumeOfLatest:Mongo.KeyPath? { get }
    /// The field to store the ``Volume.Meta`` of the **requested snapshot** in.
    static
    var volume:Mongo.KeyPath { get }

    /// The field that will contain the list of matching master records, which will become the
    /// input of the conforming type’s ``extend(pipeline:)`` witness.
    static
    var input:Mongo.KeyPath { get }

    func extend(pipeline:inout Mongo.Pipeline)
}
extension Volume.VertexQuery
{
    @inlinable public static
    var volumeOfLatest:Mongo.KeyPath? { nil }
}
extension Volume.VertexQuery
{
    @inlinable public
    var origin:Mongo.Collection { UnidocDatabase.Volumes.name }

    public
    var hint:Mongo.SortDocument?
    {
        .init
        {
            $0[Volume.Meta[.package]] = (+)
            $0[Volume.Meta[.patch]] = (-)
        }
    }

    public
    func build(pipeline:inout Mongo.Pipeline)
    {
        defer
        {
            self.extend(pipeline: &pipeline)
        }

        //  Look up the volume with the highest semantic version. Unstable and prerelease
        //  versions are not eligible.
        //
        //  This works a lot like ``Database.Names.latest(of:with:)``, except it queries the
        //  package by name instead of id.
        pipeline.stage
        {
            $0[.match] = .init
            {
                $0[Volume.Meta[.package]] = self.volume.package
                $0[Volume.Meta[.patch]] = .init { $0[.exists] = true }
            }
        }
        //  We use the patch number instead of the latest-flag because
        //  it is closer to the ground-truth, and the latest-flag doesn’t
        //  have a unique (compound) index with the package name, since
        //  it experiences rolling alignments.
        pipeline.stage
        {
            $0[.sort] = .init
            {
                $0[Volume.Meta[.patch]] = (-)
            }
        }
        pipeline.stage
        {
            $0[.limit] = 1
        }

        switch self.volume.version
        {
        case nil:
            pipeline.stage
            {
                $0[.replaceWith] = .init
                {
                    $0[Self.volume] = Mongo.Pipeline.ROOT

                    //  ``Volume.Meta`` is complex but not that large, and duplicating this
                    //  makes the rest of the query a lot simpler.
                    if  let volume:Mongo.KeyPath = Self.volumeOfLatest
                    {
                        $0[volume] = Mongo.Pipeline.ROOT
                    }
                }
            }

        case let version?:
            //  ``Volume.Meta`` has many keys. to simplify the output schema
            //  and allow re-use of the earlier pipeline stages, we demote
            //  the zone fields to a subdocument.
            //
            //  This clears the document if the ``Output`` type doesn’t have a
            //  ``volumeOfLatest`` field.
            pipeline.stage
            {
                $0[.replaceWith] = .init
                {
                    if  let volume:Mongo.KeyPath = Self.volumeOfLatest
                    {
                        $0[volume] = Mongo.Pipeline.ROOT
                    }
                }
            }

            //  If a version string was provided, use that to filter between
            //  multiple versions of the same package.
            //  This index is unique, so we don’t need a sort or a limit.
            pipeline.stage
            {
                $0[.lookup] = .init
                {
                    $0[.from] = self.origin
                    $0[.pipeline] = .init
                    {
                        $0.stage
                        {
                            $0[.match] = .init
                            {
                                $0[Volume.Meta[.package]] = self.volume.package
                                $0[Volume.Meta[.version]] = version
                            }
                        }
                    }
                    $0[.as] = Self.volume
                }
            }
            //  Unbox the single-element array. It must contain at least one element for the
            //  query to have been successful, so we can simply use an `$unwind`.
            pipeline.stage
            {
                $0[.unwind] = Self.volume
            }
        }

        pipeline.stage
        {
            self.vertex.stage(&$0, input: Self.volume, output: Self.input)
        }
    }
}
