import MongoQL
import UnidocRecords
import UnidocSelectors

extension Stages
{
    struct Zone<Selector>
    {
        let selector:Selector
        let output:Mongo.KeyPath

        init(_ selector:Selector, as output:Mongo.KeyPath)
        {
            self.selector = selector
            self.output = output
        }
    }
}
extension Stages.Zone<Selector.Zone>
{
    static
    func += (pipeline:inout Mongo.Pipeline, self:Self)
    {
        defer
        {
            //  ``Record.Zone`` has many keys. to simplify the output schema
            //  and allow re-use of the earlier pipeline stages, we demote
            //  the zone fields to a subdocument.
            pipeline.stage
            {
                $0[.replaceWith] = .init
                {
                    $0[self.output] = Mongo.Pipeline.ROOT
                }
            }
        }
        //  Look up the zone to search in.
        if  let version:Substring = self.selector.version
        {
            //  If a version string was provided, use that to filter between
            //  multiple versions of the same package.
            //  This index is unique, so we don’t need a sort or a limit.
            pipeline.stage
            {
                $0[.match] = .init
                {
                    $0[Record.Zone[.package]] = self.selector.package
                    $0[Record.Zone[.version]] = version
                }
            }
        }
        else
        {
            //  If no version string was provided, pick the one with
            //  the highest semantic version. Unstable and prerelease
            //  versions are not eligible.
            //  This works a lot like ``Database.Zones.latest(of:with:)``,
            //  except it queries the package by name instead of id.
            pipeline.stage
            {
                $0[.match] = .init
                {
                    $0[Record.Zone[.package]] = self.selector.package
                    $0[Record.Zone[.patch]] = .init
                    {
                        $0[.ne] = Never??.some(nil)
                    }
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
                    $0[Record.Zone[.patch]] = (-)
                }
            }
            pipeline.stage
            {
                $0[.limit] = 1
            }
        }
    }
}
