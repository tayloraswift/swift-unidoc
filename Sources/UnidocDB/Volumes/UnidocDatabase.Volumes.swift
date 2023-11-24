import MongoDB
import MongoQL
import Unidoc
import UnidocRecords

extension UnidocDatabase
{
    @frozen public
    struct Volumes
    {
        public
        let database:Mongo.Database

        @inlinable internal
        init(database:Mongo.Database)
        {
            self.database = database
        }
    }
}
extension UnidocDatabase.Volumes:DatabaseCollection
{
    @inlinable public static
    var name:Mongo.Collection { "names" }

    typealias ElementID = Unidoc.Edition

    static
    let indexes:[Mongo.CreateIndexStatement] =
    [
        .init
        {
            $0[.unique] = true
            $0[.name] = "id,latest"

            $0[.key] = .init
            {
                $0[Volume.Meta[.id]] = (+)
                $0[Volume.Meta[.latest]] = (-)
            }
        },
        .init
        {
            $0[.unique] = true
            $0[.name] = "id,patch"

            $0[.key] = .init
            {
                $0[Volume.Meta[.id]] = (+)
                $0[Volume.Meta[.patch]] = (-)
            }
            $0[.partialFilterExpression] = .init
            {
                $0[Volume.Meta[.patch]] = .init { $0[.exists] = true }
            }
        },
        .init
        {
            $0[.unique] = true
            $0[.name] = "package,patch"

            $0[.collation] = VolumeCollation.spec
            $0[.key] = .init
            {
                $0[Volume.Meta[.package]] = (+)
                $0[Volume.Meta[.patch]] = (-)
            }
            $0[.partialFilterExpression] = .init
            {
                $0[Volume.Meta[.patch]] = .init { $0[.exists] = true }
            }
        },
        .init
        {
            $0[.unique] = true
            $0[.name] = "package,version"

            $0[.collation] = VolumeCollation.spec
            $0[.key] = .init
            {
                $0[Volume.Meta[.package]] = (+)
                $0[Volume.Meta[.version]] = (+)
            }
        },
    ]
}
extension UnidocDatabase.Volumes:RecodableCollection
{
    public
    func recode(with session:Mongo.Session) async throws -> (modified:Int, of:Int)
    {
        try await self.recode(through: Volume.Meta.self,
            with: session,
            by: .now.advanced(by: .seconds(30)))
    }
}
extension UnidocDatabase.Volumes
{
    func find(named symbol:VolumeIdentifier,
        with session:Mongo.Session) async throws -> Volume.Meta?
    {
        let response:[Volume.Meta] = try await session.run(
            command: Mongo.Find<Mongo.SingleBatch<Volume.Meta>>.init(Self.name,
                limit: 1)
            {
                $0[.collation] = VolumeCollation.spec
                $0[.filter] = .init
                {
                    $0[Volume.Meta[.package]] = symbol.package
                    $0[Volume.Meta[.version]] = symbol.version
                }
                $0[.hint] = .init
                {

                    $0[Volume.Meta[.package]] = (+)
                    $0[Volume.Meta[.version]] = (+)
                }
            },
            against: self.database)

        return response.first
    }
}
extension UnidocDatabase.Volumes
{
    /// Returns the latest release version of the specified package, if one exists.
    func latestRelease(of package:Int32, with session:Mongo.Session) async throws -> PatchView?
    {
        let results:[PatchView] = try await session.run(
            command: self.latestRelease(of: package),
            against: self.database)
        return results.first
    }

    private
    func latestRelease(of package:Int32) -> Mongo.Find<Mongo.SingleBatch<PatchView>>
    {
        .init(Self.name, limit: 1)
        {
            $0[.filter] = .init
            {
                $0[.and] = .init
                {
                    let cell:Unidoc.Cell = .init(package: package)

                    $0.append
                    {
                        $0[Volume.Meta[.patch]] = .init { $0[.exists] = true }
                    }
                    $0.append
                    {
                        $0[Volume.Meta[.id]] = .init { $0[.gte] = cell.min }
                    }
                    $0.append
                    {
                        $0[Volume.Meta[.id]] = .init { $0[.lte] = cell.max }
                    }
                }
            }
            $0[.sort] = .init
            {
                $0[Volume.Meta[.patch]] = (-)
            }
            $0[.hint] = .init
            {
                $0[Volume.Meta[.id]] = (+)
                $0[Volume.Meta[.patch]] = (-)
            }
            $0[.projection] = .init
            {
                $0[Volume.Meta[.id]] = true
                $0[Volume.Meta[.patch]] = true
            }
        }
    }
}
extension UnidocDatabase.Volumes
{
    @discardableResult
    func align(latest zone:Unidoc.Edition, with session:Mongo.Session) async throws -> Int
    {
        let response:Mongo.UpdateResponse = try await session.run(
            command: self.align(latest: zone),
            against: self.database)
        return response.selected
    }

    private
    func align(latest zone:Unidoc.Edition) -> Mongo.Update<Mongo.Many, Unidoc.Edition>
    {
        .init(Self.name,
            updates:
            [
                //  If the record for `zone.id` doesn’t have the latest-flag, add it.
                .init
                {
                    $0[.multi] = false
                    $0[.hint] = .init
                    {
                        $0[Volume.Meta[.id]] = (+)
                        $0[Volume.Meta[.latest]] = (-)
                    }
                    $0[.q] = .init
                    {
                        $0[Volume.Meta[.id]] = zone
                        $0[Volume.Meta[.latest]] = .init { $0[.ne] = true }
                    }
                    $0[.u] = .init
                    {
                        $0[.set] = .init
                        {
                            $0[Volume.Meta[.latest]] = true
                        }
                    }
                },
                //  If any records within the same cell besides the one for `zone.id`
                //  have the latest-flag, remove it from them.
                .init
                {
                    $0[.multi] = true
                    $0[.hint] = .init
                    {
                        $0[Volume.Meta[.id]] = (+)
                        $0[Volume.Meta[.latest]] = (-)
                    }
                    $0[.q] = .init
                    {
                        $0[.and] = .init
                        {
                            $0.append
                            {
                                $0[Volume.Meta[.id]] = .init { $0[.gte] = zone.cell.min }
                            }
                            $0.append
                            {
                                $0[Volume.Meta[.id]] = .init { $0[.lte] = zone.cell.max }
                            }
                            $0.append
                            {
                                $0[Volume.Meta[.id]] = .init { $0[.ne] = zone }
                                $0[Volume.Meta[.latest]] = .init { $0[.exists] = true }
                            }
                        }
                    }
                    $0[.u] = .init
                    {
                        $0[.unset] = .init
                        {
                            $0[Volume.Meta[.latest]] = ()
                        }
                    }
                }
            ])
        {
            $0[.ordered] = false
        }
    }
}
