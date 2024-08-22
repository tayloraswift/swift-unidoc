import MD5
import MongoDB
import UnidocRecords

extension Unidoc.DB
{
    @frozen public
    struct EditionDependencies
    {
        public
        let database:Mongo.Database
        public
        let session:Mongo.Session

        @inlinable
        init(database:Mongo.Database, session:Mongo.Session)
        {
            self.database = database
            self.session = session
        }
    }
}
extension Unidoc.DB.EditionDependencies
{
    public
    static let indexSourceChangedABI:Mongo.CollectionIndex = .init("SourceChangedABI",
        collation: SimpleCollation.spec)
    {
        $0[Unidoc.EditionDependency[.id] / Unidoc.Edge<Unidoc.Edition>[.source]] = (+)
    }
        where:
    {
        $0[Unidoc.EditionDependency[.targetChanged]] = true
    }

    public
    static let indexSource:Mongo.CollectionIndex = .init("Source",
        collation: SimpleCollation.spec)
    {
        $0[Unidoc.EditionDependency[.id] / Unidoc.Edge<Unidoc.Edition>[.source]] = (+)
    }

    public
    static let indexTarget:Mongo.CollectionIndex = .init("Target",
        collation: SimpleCollation.spec)
    {
        $0[Unidoc.EditionDependency[.id] / Unidoc.Edge<Unidoc.Edition>[.target]] = (+)
    }
}
extension Unidoc.DB.EditionDependencies:Mongo.CollectionModel
{
    public
    typealias Element = Unidoc.EditionDependency

    @inlinable public
    static var name:Mongo.Collection { "EditionDependencies" }

    @inlinable public
    static var indexes:[Mongo.CollectionIndex]
    {
        [
            Self.indexSourceChangedABI,
            Self.indexSource,
            Self.indexTarget
        ]
    }
}
extension Unidoc.DB.EditionDependencies
{
    func create(dependent:Unidoc.Edition,
        from boundaries:[Unidoc.Mesh.Boundary]) async throws
    {
        let dependencies:[Unidoc.EditionDependency] = boundaries.reduce(into: [])
        {
            if  let edition:Unidoc.Edition = $1.target.pin?.edition
            {
                $0.append(.init(source: dependent, target: edition, targetABI: $1.targetABI))
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

    func clear(dependent:Unidoc.Edition) async throws
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
                        $0[Element[.id] / Unidoc.Edge<Unidoc.Edition>[.source]] = dependent
                    }
                }
            },
            against: self.database)

        let _:Mongo.Deletions = try response.deletions()
    }

    /// Selects all edges whose target matches `dependency` and marks them as dirty if their
    /// ``Unidoc.EditionDependency/targetABI`` does not match `dependencyABI`.
    @discardableResult
    func update(dependencyABI:MD5,
        dependency:Unidoc.Edition) async throws -> Int
    {
        try await self.updateMany
        {
            $0
            {
                $0[.multi] = true
                $0[.q]
                {
                    $0[Element[.id] / Unidoc.Edge<Unidoc.Edition>[.target]] = dependency
                    $0[Element[.targetABI]] { $0[.ne] = dependencyABI }
                }
                $0[.u]
                {
                    $0[.set]
                    {
                        $0[Element[.targetABI]] = dependencyABI
                        $0[Element[.targetChanged]] = true
                    }
                }
            }
        }
    }
}
