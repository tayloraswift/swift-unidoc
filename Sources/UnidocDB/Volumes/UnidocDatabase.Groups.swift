import MongoDB
import Unidoc
import UnidocRecords

extension UnidocDatabase
{
    @frozen public
    struct Groups
    {
        public
        let database:Mongo.Database

        init(database:Mongo.Database)
        {
            self.database = database
        }
    }
}
extension UnidocDatabase.Groups:Mongo.CollectionModel
{
    public
    typealias Element = Volume.Group

    @inlinable public static
    var name:Mongo.Collection { "VolumeGroups" }

    public static
    let indexes:[Mongo.CollectionIndex] =
    [
        .init("ScopeLatest")
        {
            $0[Volume.Group[.scope]] = (+)
            $0[Volume.Group[.latest]] = (-)
        },
        .init("Scope", unique: true)
        {
            $0[Volume.Group[.scope]] = (+)
            $0[Volume.Group[.id]] = (+)
        },
    ]
}
extension UnidocDatabase.Groups
{
    func align(latest zone:Unidoc.Edition,
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
    func align(latest zone:Unidoc.Edition, with session:Mongo.Session) async throws -> Int
    {
        let response:Mongo.UpdateResponse = try await session.run(
            command: self.align(latest: zone),
            against: self.database)
        return response.selected
    }

    private
    func align(latest zone:Unidoc.Edition) -> Mongo.Update<Mongo.Many, Unidoc.Scalar>
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
                                $0[Volume.Group[.id]] = .init { $0[.gte] = zone.min }
                            }
                            $0.append
                            {
                                $0[Volume.Group[.id]] = .init { $0[.lte] = zone.max }
                            }
                            $0.append
                            {
                                $0[Volume.Group[.latest]] = .init { $0[.ne] = true }
                            }
                        }
                    }
                    $0[.u] = .init
                    {
                        $0[.set] = .init
                        {
                            $0[Volume.Group[.latest]] = true
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
                                $0[Volume.Group[.id]] = .init { $0[.gte] = cell.min.min }
                            }
                            $0.append
                            {
                                $0[Volume.Group[.id]] = .init { $0[.lte] = cell.max.max }
                            }
                            $0.append
                            {
                                $0[.or] = .init
                                {
                                    $0.append
                                    {
                                        $0[Volume.Group[.id]] = .init { $0[.lt] = zone.min }
                                    }
                                    $0.append
                                    {
                                        $0[Volume.Group[.id]] = .init { $0[.gt] = zone.max }
                                    }
                                }
                            }
                            $0.append
                            {
                                $0[Volume.Group[.latest]] = .init { $0[.exists] = true }
                            }
                        }
                    }
                    $0[.u] = .init
                    {
                        $0[.unset] = .init
                        {
                            $0[Volume.Group[.latest]] = ()
                        }
                    }
                }
            ])
        {
            $0[.ordered] = false
        }
    }
}
