
import MongoQL
import UnidocDB
import UnidocRecords

public
protocol VolumeLookupQuery:DatabaseQuery where Collation == VolumeCollation
{
    associatedtype LookupPredicate:VolumeLookupPredicate

    var volume:Volume.Selector { get }
    var lookup:LookupPredicate { get }

    /// The field to store the ``Volume.Names`` of the **latest stable release**
    /// (relative to the current volume) in.
    ///
    /// If nil, the query will still look up the latest stable release, but the result will
    /// be discarded.
    static
    var namesOfLatest:Mongo.KeyPath? { get }
    /// The field to store the ``Volume.Names`` of the **requested snapshot** in.
    static
    var names:Mongo.KeyPath { get }

    /// The field that will contain the list of matching master records, which will become the
    /// input of the conforming type’s ``extend(pipeline:)`` witness.
    static
    var input:Mongo.KeyPath { get }

    func extend(pipeline:inout Mongo.Pipeline)
}
extension VolumeLookupQuery
{
    @inlinable public static
    var namesOfLatest:Mongo.KeyPath? { nil }
}
extension VolumeLookupQuery
{
    @inlinable public
    var origin:Mongo.Collection { UnidocDatabase.Names.name }

    public
    var hint:Mongo.SortDocument?
    {
        .init
        {
            $0[Volume.Names[.package]] = (+)
            $0[Volume.Names[.patch]] = (-)
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
                $0[Volume.Names[.package]] = self.volume.package
                $0[Volume.Names[.patch]] = .init { $0[.exists] = true }
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
                $0[Volume.Names[.patch]] = (-)
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
                    $0[Self.names] = Mongo.Pipeline.ROOT
                }
            }

        case let version?:
            //  ``Volume.Names`` has many keys. to simplify the output schema
            //  and allow re-use of the earlier pipeline stages, we demote
            //  the zone fields to a subdocument.
            //
            //  This clears the document if the ``Output`` type doesn’t have a
            //  ``namesOfLatest`` field.
            pipeline.stage
            {
                $0[.replaceWith] = .init
                {
                    if  let names:Mongo.KeyPath = Self.namesOfLatest
                    {
                        $0[names] = Mongo.Pipeline.ROOT
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
                                $0[Volume.Names[.package]] = self.volume.package
                                $0[Volume.Names[.version]] = version
                            }
                        }
                    }
                    $0[.as] = Self.names
                }
            }
            //  Unbox the single-element array. It must contain at least one element for the
            //  query to have been successful, so we can simply use an `$unwind`.
            pipeline.stage
            {
                $0[.unwind] = Self.names
            }
        }

        pipeline.stage
        {
            self.lookup.stage(&$0, input: Self.names, output: Self.input)
        }
    }
}
