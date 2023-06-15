import MongoDB
import ModuleGraphs
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
    func push(docs:Documentation) async throws -> ObjectReceipt
    {
        try await self.push(docs: docs, with: try await .init(from: self.pool))
    }
    public
    func push(docs:Documentation,
        with session:Mongo.Session) async throws -> ObjectReceipt
    {
        let id:String = docs.metadata.id ?? "$anonymous"
        // guard let id:String = docs.metadata.id
        // else
        // {
        //     throw DocumentationIdentificationError.init()
        // }

        let package:Int32 = try await self.packages.register(docs.metadata.package,
            with: session)
        switch try await self.objects.push(docs, for: package, as: id,
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
    func publish(projecting docs:__owned Documentation,
        with session:__shared Mongo.Session) async throws
    {
        var linker:DynamicLinker = .init(context: try await self.context(
            publishing: docs,
            with: session))
        let _:[ScalarProjection] = linker.project()
    }
    private
    func context(publishing docs:__owned Documentation,
        with session:__shared Mongo.Session) async throws -> GlobalContext
    {
        let dependencies:[DynamicObject] = try await self.objects.load(docs.metadata.pins(),
            with: session)

        let translators:[DynamicObject.Translator] = try dependencies.map
        {
            try .init(policies: self.policies, object: $0)
        }

        var upstream:UpstreamSymbols = .init()

        for (translator, object):(DynamicObject.Translator, DynamicObject) in
            zip(translators, dependencies)
        {
            for (address, symbol):(Int32, ScalarSymbol) in object.graph.citizens
            {
                upstream.scalars[symbol] = translator[scalar: address]
            }
            for (culture, symbol):(Int, ModuleIdentifier) in zip(
                object.graph.cultures.indices,
                object.graph.namespaces)
            {
                upstream.modules[symbol] = translator[culture: culture]
            }
        }
        //  Populate the context with the current package’s docs.
        var context:GlobalContext = .init(current: .init(projector: try .init(
                policies: self.policies,
                upstream: upstream,
                receipt: try await self.push(docs: docs, with: session),
                graph: docs.graph),
            graph: docs.graph))

        //  Populate the context with the docs of all the package’s upstream dependencies.
        for (translator, object):(DynamicObject.Translator, DynamicObject) in
            zip(translators, dependencies)
        {
            context.upstream[object.package] = .init(projector: .init(
                    translator: translator,
                    upstream: upstream,
                    graph: object.graph),
                graph: object.graph)
        }
        return context
    }
}
