import ModuleGraphs
import MongoDB

extension DocumentationDatabase
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
extension DocumentationDatabase.Packages
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
                        $0[.name] = "\(Self.name)(\(PackageRegistration[.address]))"
                        $0[.key] = .init
                        {
                            $0[PackageRegistration[.address]] = (-)
                        }
                    },
                ]),
            against: self.database)

        assert(response.indexesAfter == 2)
    }

    //  TODO: consider caching package identifier addresses?

    /// Registers the given package identifier in the database, returning its address.
    /// This is really just a glorified string internment system.
    ///
    /// This function is very expensive. It only makes one query if the package is
    /// already registered, but can take up to three round trips to intern the
    /// identifier otherwise.
    public
    func register(_ package:PackageIdentifier,
        with session:Mongo.Session) async throws -> Int32
    {
        let result:Mongo.TransactionResult = await session.withSnapshotTransaction(
            writeConcern: .majority)
        {
            try await self.register(package, with: $0)
        }
        return try result()
    }

    private
    func register(_ package:PackageIdentifier,
        with transaction:Mongo.Transaction) async throws -> Int32
    {
        let registered:[PackageRegistration] = try await transaction.run(
            command: Mongo.Find<Mongo.SingleBatch<PackageRegistration>>.init(Self.name,
                limit: 1)
            {
                $0[.filter] = .init
                {
                    $0[PackageRegistration[.id]] = package
                }
            },
            against: self.database)

        if  let registered:PackageRegistration = registered.first
        {
            return registered.address
        }

        let unregistered:PackageRegistration = try await transaction.run(
            command: Mongo.Aggregate<Mongo.Cursor<PackageRegistration>>.init(Self.name,
                pipeline: .init
                {
                    $0.stage
                    {
                        $0[.sort] = .init
                        {
                            $0[PackageRegistration[.address]] = (-)
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
                            $0[PackageRegistration[.id]] = package
                            $0[PackageRegistration[.address]] = .expr
                            {
                                $0[.add] = ("$\(PackageRegistration[.address])", 1)
                            }
                        }
                    }
                },
                stride: 1)
                {
                    $0[.hint] = .init
                    {
                        $0[PackageRegistration[.address]] = (-)
                    }
                },
            against: self.database)
        {
            //  If there are no results, the collection is completely uninitialized,
            //  and we should start the count from zero.
            try await $0.reduce(into: [], +=).first ?? .init(id: package, address: 0)
        }

        let response:Mongo.InsertResponse = try await transaction.run(
            command: Mongo.Insert.init(Self.name, encoding: [unregistered]),
            against: self.database)

        if  response.inserted == 1
        {
            return unregistered.address
        }
        else
        {
            throw PackageRegistrationError.init(id: package)
        }
    }
}
