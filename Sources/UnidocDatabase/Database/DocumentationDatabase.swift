import SymbolGraphs
import MongoDB

@frozen public
struct DocumentationDatabase
{
    private
    let pool:Mongo.SessionPool
    public
    let name:Mongo.Database

    private
    init(pool:Mongo.SessionPool, name:Mongo.Database)
    {
        self.name = name
        self.pool = pool
    }
}
extension DocumentationDatabase
{
    @inlinable public
    var packages:Packages { .init(database: self.name) }
    @inlinable public
    var objects:Objects { .init(database: self.name) }
}
extension DocumentationDatabase
{
    public static
    func setup(mongodb pool:__owned Mongo.SessionPool, name:Mongo.Database) async throws -> Self
    {
        let database:Self = .init(pool: pool, name: name)
        try await database.setup()
        return database
    }

    private
    func setup() async throws
    {
        try await self.packages.setup(with: try await .init(from: self.pool))
        try await self.objects.setup(with: try await .init(from: self.pool))
    }
}
extension DocumentationDatabase
{
    public
    func push(archive:DocumentationArchive) async throws -> ObjectReceipt
    {
        try await self.push(archive: archive, with: try await .init(from: self.pool))
    }
    public
    func push(archive:DocumentationArchive,
        with session:Mongo.Session) async throws -> ObjectReceipt
    {
        guard let id:String = archive.metadata.id
        else
        {
            throw DocumentationIdentificationError.init()
        }

        let package:Int32 = try await self.packages.register(archive.metadata.package,
            with: session)
        switch try await self.objects.push(archive, for: package, as: id,
            with: session)
        {
        case (let version, overwritten: let overwritten):
            return .init(overwritten: overwritten, package: package, version: version)
        }
    }
}
