
import MongoQL
import UnidocDB
import UnidocRecords

public
protocol VolumeLookupQuery:DatabaseQuery where Database == UnidocDatabase
{
    associatedtype LookupPredicate:VolumeLookupPredicate

    var volume:Volume.Selector { get }
    var lookup:LookupPredicate { get }

    static
    var names:Mongo.KeyPath { get }
    static
    var input:Mongo.KeyPath { get }

    func extend(pipeline:inout Mongo.Pipeline)
}
extension VolumeLookupQuery
{
    @inlinable public
    var origin:Mongo.Collection { UnidocDatabase.Names.name }

    public
    var hint:Mongo.SortDocument? { self.volume.hint }

    public
    func build(pipeline:inout Mongo.Pipeline)
    {
        defer
        {
            self.extend(pipeline: &pipeline)
        }

        //  Look up the zone to search in.
        if  let version:Substring = self.volume.version
        {
            //  If a version string was provided, use that to filter between
            //  multiple versions of the same package.
            //  This index is unique, so we don’t need a sort or a limit.
            pipeline.stage
            {
                $0[.match] = .init
                {
                    $0[Volume.Names[.package]] = self.volume.package
                    $0[Volume.Names[.version]] = version
                }
            }
        }
        else
        {
            //  If no version string was provided, pick the one with
            //  the highest semantic version. Unstable and prerelease
            //  versions are not eligible.
            //  This works a lot like ``Database.Names.latest(of:with:)``,
            //  except it queries the package by name instead of id.
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
        }

        //  ``Volume.Names`` has many keys. to simplify the output schema
        //  and allow re-use of the earlier pipeline stages, we demote
        //  the zone fields to a subdocument.
        pipeline.stage
        {
            $0[.replaceWith] = .init
            {
                $0[Self.names] = Mongo.Pipeline.ROOT
            }
        }

        pipeline.stage
        {
            self.lookup.stage(&$0, input: Self.names, output: Self.input)
        }
    }
}
