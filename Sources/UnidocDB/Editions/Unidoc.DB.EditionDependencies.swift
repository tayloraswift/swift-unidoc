import MongoDB
import UnidocRecords

extension Unidoc.DB
{
    @frozen public
    struct EditionDependencies
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
extension Unidoc.DB.EditionDependencies
{
    public static
    let indexSource:Mongo.CollectionIndex = .init("Source",
        collation: SimpleCollation.spec)
    {
        $0[Unidoc.EditionDependency[.id] / Unidoc.Edge<Unidoc.Edition>[.source]] = (+)
    }

    public static
    let indexTarget:Mongo.CollectionIndex = .init("Target",
        collation: SimpleCollation.spec)
    {
        $0[Unidoc.EditionDependency[.id] / Unidoc.Edge<Unidoc.Edition>[.target]] = (+)
    }
}
extension Unidoc.DB.EditionDependencies:Mongo.CollectionModel
{
    public
    typealias Element = Unidoc.EditionDependency

    @inlinable public static
    var name:Mongo.Collection { "EditionDependencies" }

    @inlinable public static
    var indexes:[Mongo.CollectionIndex]
    {
        [
            Self.indexSource,
            Self.indexTarget
        ]
    }
}
extension Unidoc.DB.EditionDependencies
{
    func insert(dependencies:[Unidoc.VolumeMetadata.Dependency],
        dependent source:Unidoc.Edition,
        with session:Mongo.Session) async throws
    {
        let dependencies:[Unidoc.EditionDependency] = dependencies.reduce(into: [])
        {
            if  let edition:Unidoc.Edition = $1.pin?.edition
            {
                $0.append(.init(source: source, target: edition))
            }
        }

        if  dependencies.isEmpty
        {
            return
        }

        let response:Mongo.InsertResponse = try await session.run(
            command: Mongo.Insert.init(Self.name, encoding: dependencies),
            against: self.database)

        let _:Mongo.Insertions = try response.insertions()
    }

    func clear(dependent source:Unidoc.Edition, with session:Mongo.Session) async throws
    {
        let response:Mongo.DeleteResponse = try await session.run(
            command: Mongo.Delete<Mongo.Many>.init(Self.name)
            {
                $0
                {
                    $0[.limit] = .unlimited
                    $0[.hint] = Self.indexSource.id
                    $0[.q]
                    {
                        $0[Element[.id] / Unidoc.Edge<Unidoc.Edition>[.source]] = source
                    }
                }
            },
            against: self.database)

        let _:Mongo.Deletions = try response.deletions()
    }
}
