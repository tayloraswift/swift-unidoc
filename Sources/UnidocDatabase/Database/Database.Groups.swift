import MongoDB
import Unidoc
import UnidocRecords

extension Database
{
    public
    struct Groups
    {
        let database:Mongo.Database

        init(database:Mongo.Database)
        {
            self.database = database
        }
    }
}
extension Database.Groups:DatabaseCollection
{
    typealias ElementID = Unidoc.Scalar

    @inlinable public static
    var name:Mongo.Collection { "groups" }
}
extension Database.Groups
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
                        $0[.name] = "id"
                        $0[.key] = .init
                        {
                            $0[Record.Group[.id]] = (+)
                            $0[Record.Group[.latest]] = (-)
                        }
                    },
                    .init
                    {
                        $0[.unique] = false
                        $0[.name] = "scope"
                        $0[.key] = .init
                        {
                            $0[Record.Group[.scope]] = (+)
                            $0[Record.Group[.latest]] = (-)
                        }
                    },
                ]),
            against: self.database)

        assert(response.indexesAfter == 3)
    }
}
extension Database.Groups
{
    func align(latest zone:Unidoc.Zone,
        with session:Mongo.Session,
        explain:()) async throws -> String
    {
        try await session.run(
            command: Mongo.Explain<Mongo.Update<Mongo.Many, Unidoc.Scalar>>.init(
                verbosity: .executionStats,
                command: self.align(latest: zone)),
            against: self.database)
    }
    @discardableResult
    func align(latest zone:Unidoc.Zone, with session:Mongo.Session) async throws -> Int
    {
        let response:Mongo.UpdateResponse = try await session.run(
            command: self.align(latest: zone),
            against: self.database)
        return response.selected
    }

    private
    func align(latest zone:Unidoc.Zone) -> Mongo.Update<Mongo.Many, Unidoc.Scalar>
    {
        .init(Self.name,
            updates:
            [
                //  If any records within the specified zone lack the latest-flag,
                //  add it to them.
                .init
                {
                    $0[.multi] = true
                    $0[.q] = .init
                    {
                        $0[.and] = .init
                        {
                            $0.append
                            {
                                $0[Record.Group[.id]] = .init { $0[.gte] = zone.min }
                            }
                            $0.append
                            {
                                $0[Record.Group[.id]] = .init { $0[.lte] = zone.max }
                            }
                            $0.append
                            {
                                $0[Record.Group[.latest]] = .init { $0[.ne] = true }
                            }
                        }
                    }
                    $0[.u] = .init
                    {
                        $0[.set] = .init
                        {
                            $0[Record.Group[.latest]] = true
                        }
                    }
                },
                //  If any records within the same cell but not within the specified zone
                //  have the latest-flag, remove it from them.
                .init
                {
                    $0[.multi] = true
                    $0[.q] = .init
                    {
                        $0[.and] = .init
                        {
                            let cell:Unidoc.Cell = zone.cell

                            $0.append
                            {
                                $0[Record.Group[.id]] = .init { $0[.gte] = cell.min.min }
                            }
                            $0.append
                            {
                                $0[Record.Group[.id]] = .init { $0[.lte] = cell.max.max }
                            }
                            $0.append
                            {
                                $0[.or] = .init
                                {
                                    $0.append
                                    {
                                        $0[Record.Group[.id]] = .init { $0[.lt] = zone.min }
                                    }
                                    $0.append
                                    {
                                        $0[Record.Group[.id]] = .init { $0[.gt] = zone.max }
                                    }
                                }
                            }
                            $0.append
                            {
                                $0[Record.Group[.latest]] = .init { $0[.exists] = true }
                            }
                        }
                    }
                    $0[.u] = .init
                    {
                        $0[.unset] = .init
                        {
                            $0[Record.Group[.latest]] = ()
                        }
                    }
                }
            ])
        {
            $0[.ordered] = false
        }
    }
}
