import BSON
import ModuleGraphs
import MongoDB
import UnidocAnalysis
import UnidocRecords

extension Database
{
    @frozen public
    struct Packages
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
extension Database.Packages
{
    @inlinable public static
    var name:Mongo.Collection { "packages" }

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
                        $0[.name] = "cell"
                        $0[.key] = .init
                        {
                            $0[Cell[.index]] = (-)
                        }
                    },
                ]),
            against: self.database)

        assert(response.indexesAfter == 2)
    }

    //  TODO: consider caching package identifier addresses?

    /// Registers the given package identifier in the database, returning its cell.
    /// This is really just a glorified string internment system.
    ///
    /// This function can be expensive. It only makes one query if the package is already
    /// registered, but can take two round trips to intern the identifier otherwise.
    public
    func register(_ package:PackageIdentifier,
        with session:Mongo.Session) async throws -> Registration
    {
        //  This used to be a transaction, but we cannot use `$unionWith` in a transaction,
        //  and transactions aren’t going to scale for what we need to do afterwards.
        //  (e.g. regenerating the all-package search index.)
        let registration:Registration = try await session.run(
            command: Mongo.Aggregate<Mongo.Cursor<Registration>>.init(Self.name,
                pipeline: .init
                {
                    $0.stage
                    {
                        $0[.match] = .init
                        {
                            $0[Cell[.id]] = package
                        }
                    }
                    $0.stage
                    {
                        $0[.replaceWith] = .init
                        {
                            $0[Registration[.cell]] = Cell[.index]
                            $0[Registration[.new]] = false
                        }
                    }
                    $0.stage
                    {
                        $0[.unionWith] = .init
                        {
                            $0[.collection] = Self.name
                            $0[.pipeline] = .init
                            {
                                $0.stage
                                {
                                    $0[.sort] = .init
                                    {
                                        $0[Cell[.index]] = (-)
                                    }
                                }
                                $0.stage
                                {
                                    $0[.limit] = 1
                                }
                                $0.stage
                                {
                                    $0[.replaceWith] = .init
                                    {
                                        $0[Registration[.cell]] = .expr
                                        {
                                            $0[.add] = (Cell[.index], 1)
                                        }
                                        $0[Registration[.new]] = true
                                    }
                                }
                            }
                        }
                    }
                    //  Prefer existing registrations, if any.
                    $0.stage
                    {
                        $0[.sort] = .init
                        {
                            $0[Registration[.cell]] = (+)
                        }
                    }
                    $0.stage
                    {
                        $0[.limit] = 1
                    }
                },
                stride: 1),
            against: self.database)
        {
            //  If there are no results, the collection is completely uninitialized,
            //  and we should start the count from zero.
            try await $0.reduce(into: [], +=).first ?? .init(cell: 0, new: true)
        }

        guard registration.new
        else
        {
            return registration
        }

        let cell:Cell = .init(id: package, index: registration.cell)

        let response:Mongo.InsertResponse = try await session.run(
            command: Mongo.Insert.init(Self.name, encoding: [cell]),
            against: self.database)

        if  response.inserted == 1
        {
            return registration
        }
        else
        {
            throw RegistrationError.init(id: package)
        }
    }

    func scan(with session:Mongo.Session) async throws -> Record.SearchIndex<Never?>
    {
        let json:JSON = try await .array
        {
            (json:inout JSON.ArrayEncoder) in

            try await session.run(
                command: Mongo.Find<Mongo.Cursor<Cell>>.init(Self.name, stride: 1024),
                against: self.database)
            {
                for try await batch:[Cell] in $0
                {
                    for cell:Cell in batch
                    {
                        json[+] = "\(cell.id)"
                    }
                }
            }
        }

        return .init(json: json)
    }
}
