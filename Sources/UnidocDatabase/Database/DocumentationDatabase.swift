import MongoDB
import SymbolGraphs
import Symbols

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
    var policies:Policies { .init() }

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
extension DocumentationDatabase
{
    public
    func publish(projecting archive:__owned DocumentationArchive,
        with session:__shared Mongo.Session) async throws
    {
        let context:GlobalContext = try await self.context(publishing: archive, with: session)
        let _:[ScalarProjection] = context.project()
    }
    private
    func context(publishing archive:__owned DocumentationArchive,
        with session:__shared Mongo.Session) async throws -> GlobalContext
    {
        let dependencies:[DocumentationObject] = try await self.objects.load(
            archive.metadata.pins(),
            with: session)

        let translators:[DocumentationObject.Translator] = try dependencies.map
        {
            try .init(policies: self.policies, object: $0)
        }

        var upstream:[ScalarSymbol: GlobalAddress] = [:]

        for (translator, object):(DocumentationObject.Translator, DocumentationObject) in
            zip(translators, dependencies)
        {
            for (offset, symbol):(Int, ScalarSymbol) in object.docs.graph.citizens
            {
                upstream[symbol] = translator[scalar: offset]
            }
        }

        var context:GlobalContext = .init(current: .init(projector: try .init(
                policies: self.policies,
                upstream: upstream,
                receipt: try await self.push(archive: archive, with: session),
                docs: archive.docs),
            docs: archive.docs))

        for (translator, object):(DocumentationObject.Translator, DocumentationObject) in
            zip(translators, dependencies)
        {
            context.upstream[object.package] = .init(projector: .init(
                    translator: translator,
                    upstream: upstream,
                    docs: object.docs),
                docs: object.docs)
        }
        return context
    }
}
