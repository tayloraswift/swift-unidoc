import MongoQL
import MongoDB
import UnidocRecords

extension Unidoc.DB
{
    @frozen public
    struct PackageDependencies
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
extension Unidoc.DB.PackageDependencies
{
    public static
    let indexSource:Mongo.CollectionIndex = .init("Source/2",
        collation: SimpleCollation.spec)
    {
        $0[Unidoc.PackageDependency[.id] / Unidoc.Edge<Unidoc.Package>[.source]] = (+)
        $0[Unidoc.PackageDependency[.source]] = (+)
    }

    public static
    let indexTarget:Mongo.CollectionIndex = .init("Target",
        collation: SimpleCollation.spec)
    {
        $0[Unidoc.PackageDependency[.id] / Unidoc.Edge<Unidoc.Package>[.target]] = (+)
    }
}
extension Unidoc.DB.PackageDependencies:Mongo.CollectionModel
{
    public
    typealias Element = Unidoc.PackageDependency

    @inlinable public static
    var name:Mongo.Collection { "PackageDependencies" }

    @inlinable public static
    var indexes:[Mongo.CollectionIndex]
    {
        [
            Self.indexSource,
            Self.indexTarget
        ]
    }
}
extension Unidoc.DB.PackageDependencies:Mongo.RecodableModel
{
    public
    func recode(with session:Mongo.Session) async throws -> (modified:Int, of:Int)
    {
        try await self.recode(through: Unidoc.PackageDependency.self,
            with: session,
            by: .now.advanced(by: .seconds(30)))
    }
}
extension Unidoc.DB.PackageDependencies
{
    func update(dependent source:Unidoc.Edition,
        from boundaries:[Unidoc.Mesh.Boundary],
        with session:Mongo.Session) async throws
    {
        let dependencies:[Unidoc.PackageDependency] = boundaries.reduce(into: [])
        {
            if  let package:Unidoc.Package = $1.target.pin?.edition.package
            {
                $0.append(.init(source: source, target: package))
            }
        }

        if  dependencies.isEmpty
        {
            return
        }
        //  Upsert new edges.
        let upsertion:Mongo.UpdateResponse<Unidoc.Edge<Unidoc.Package>> = try await session.run(
            command: Mongo.Update<Mongo.One, Unidoc.Edge<Unidoc.Package>>.init(Self.name)
            {
                for dependency:Unidoc.PackageDependency in dependencies
                {
                    $0
                    {
                        $0[.upsert] = true
                        $0[.q] { $0[Element[.id]] = dependency.id }
                        $0[.u] = dependency
                    }
                }
            },
            against: self.database)

        let _:Mongo.Updates = try upsertion.updates()

        //  Vacuum old edges from previous versions.
        let deletion:Mongo.DeleteResponse = try await session.run(
            command: Mongo.Delete<Mongo.Many>.init(Self.name)
            {
                $0
                {
                    $0[.limit] = .unlimited
                    $0[.hint] = Self.indexSource.id
                    $0[.q]
                    {
                        $0[Element[.id] / Unidoc.Edge<Unidoc.Package>[.source]] = source.package
                        $0[Element[.source]] { $0[.ne] = source }
                    }
                }
            },
            against: self.database)

        let _:Mongo.Deletions = try deletion.deletions()
    }

    /// If `source` is a Latest Release Version, this method **will not** restore the edges that
    /// existed prior to the latest release.
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
                        $0[Element[.id] / Unidoc.Edge<Unidoc.Package>[.source]] = source.package
                        $0[Element[.source]] = source
                    }
                }
            },
            against: self.database)

        let _:Mongo.Deletions = try response.deletions()
    }
}
