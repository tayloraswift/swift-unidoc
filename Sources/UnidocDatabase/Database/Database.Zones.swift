import ModuleGraphs
import MongoDB
import Unidoc
import UnidocRecords

extension Database
{
    public
    struct Zones
    {
        let database:Mongo.Database

        init(database:Mongo.Database)
        {
            self.database = database
        }
    }
}
extension Database.Zones:DatabaseCollection
{
    typealias ElementID = Unidoc.Zone

    @inlinable public static
    var name:Mongo.Collection { "zones" }
}
extension Database.Zones
{
    func setup(with session:Mongo.Session) async throws
    {
        let response:Mongo.CreateIndexesResponse = try await session.run(
            command: Mongo.CreateIndexes.init(Self.name,
                writeConcern: .majority,
                indexes:
                [
                    .init
                    {
                        $0[.unique] = true
                        $0[.name] = "id,latest"

                        $0[.key] = .init
                        {
                            $0[Record.Zone[.id]] = (+)
                            $0[Record.Zone[.latest]] = (-)
                        }
                    },
                    .init
                    {
                        $0[.unique] = true
                        $0[.name] = "id,patch"

                        $0[.key] = .init
                        {
                            $0[Record.Zone[.id]] = (+)
                            $0[Record.Zone[.patch]] = (-)
                        }
                        $0[.partialFilterExpression] = .init
                        {
                            $0[Record.Zone[.patch]] = .init { $0[.exists] = true }
                        }
                    },
                    .init
                    {
                        $0[.unique] = true
                        $0[.name] = "package,patch"

                        $0[.key] = .init
                        {
                            $0[Record.Zone[.package]] = (+)
                            $0[Record.Zone[.patch]] = (-)
                        }
                        $0[.partialFilterExpression] = .init
                        {
                            $0[Record.Zone[.patch]] = .init { $0[.exists] = true }
                        }
                    },
                    .init
                    {
                        $0[.unique] = true
                        $0[.name] = "package,version"

                        $0[.key] = .init
                        {
                            $0[Record.Zone[.package]] = (+)
                            $0[Record.Zone[.version]] = (+)
                        }
                    },
                ]),
            against: self.database)

        assert(response.indexesAfter == 5)
    }
}
extension Database.Zones
{
    /// Returns the latest release version of the specified package, if one exists.
    func latest(of cell:Unidoc.Cell, with session:Mongo.Session) async throws -> PatchView?
    {
        let results:[PatchView] = try await session.run(
            command: self.latest(of: cell),
            against: self.database)
        return results.first
    }

    private
    func latest(of cell:Unidoc.Cell) -> Mongo.Find<Mongo.SingleBatch<PatchView>>
    {
        .init(Self.name, limit: 1)
        {
            $0[.filter] = .init
            {
                $0[.and] = .init
                {
                    $0.append
                    {
                        $0[Record.Zone[.patch]] = .init { $0[.exists] = true }
                    }
                    $0.append
                    {
                        $0[Record.Zone[.id]] = .init { $0[.gte] = cell.min }
                    }
                    $0.append
                    {
                        $0[Record.Zone[.id]] = .init { $0[.lte] = cell.max }
                    }
                }
            }
            $0[.sort] = .init
            {
                $0[Record.Zone[.patch]] = (-)
            }
            $0[.hint] = .init
            {
                $0[Record.Zone[.id]] = (+)
                $0[Record.Zone[.patch]] = (-)
            }
            $0[.projection] = .init
            {
                $0[Record.Zone[.id]] = true
                $0[Record.Zone[.patch]] = true
            }
        }
    }
}
extension Database.Zones
{
    @discardableResult
    func align(latest zone:Unidoc.Zone, with session:Mongo.Session) async throws -> Int
    {
        let response:Mongo.UpdateResponse = try await session.run(
            command: self.align(latest: zone),
            against: self.database)
        return response.selected
    }

    private
    func align(latest zone:Unidoc.Zone) -> Mongo.Update<Mongo.Many, Unidoc.Zone>
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
                        $0[Record.Zone[.id]] = (+)
                        $0[Record.Zone[.latest]] = (-)
                    }
                    $0[.q] = .init
                    {
                        $0[Record.Zone[.id]] = zone
                        $0[Record.Zone[.latest]] = .init { $0[.ne] = true }
                    }
                    $0[.u] = .init
                    {
                        $0[.set] = .init
                        {
                            $0[Record.Zone[.latest]] = true
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
                        $0[Record.Zone[.id]] = (+)
                        $0[Record.Zone[.latest]] = (-)
                    }
                    $0[.q] = .init
                    {
                        $0[.and] = .init
                        {
                            $0.append
                            {
                                $0[Record.Zone[.id]] = .init { $0[.gte] = zone.cell.min }
                            }
                            $0.append
                            {
                                $0[Record.Zone[.id]] = .init { $0[.lte] = zone.cell.max }
                            }
                            $0.append
                            {
                                $0[Record.Zone[.id]] = .init { $0[.ne] = zone }
                                $0[Record.Zone[.latest]] = .init { $0[.exists] = true }
                            }
                        }
                    }
                    $0[.u] = .init
                    {
                        $0[.unset] = .init
                        {
                            $0[Record.Zone[.latest]] = ()
                        }
                    }
                }
            ])
        {
            $0[.ordered] = false
        }
    }
}
