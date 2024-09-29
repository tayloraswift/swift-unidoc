import MongoDB

//  TODO: we need to unify ``Unidoc.Scalar`` and ``Unidoc.Group`, most likely by introducing
//  a new type ``Unidoc.Vertex``.
extension Mongo.CollectionModel where Element.ID == Unidoc.Scalar
{
    /// Deletes all records from the collection within the specified volume.
    func deleteAll(in range:Unidoc.Edition) async throws
    {
        try await self.clear(range: range)
    }
}
extension Mongo.CollectionModel where Element.ID == Unidoc.Group
{
    /// Deletes all records from the collection within the specified volume.
    func deleteAll(in range:Unidoc.Edition) async throws
    {
        try await self.clear(range: range)
    }
}
extension Mongo.CollectionModel
{
    /// Deletes all records from the collection within the specified volume.
    private
    func clear(range:Unidoc.Edition) async throws
    {
        let response:Mongo.DeleteResponse = try await session.run(
            command: Mongo.Delete<Mongo.Many>.init(Self.name)
            {
                $0
                {
                    $0[.limit] = .unlimited
                    $0[.q]
                    {
                        $0[.and]
                        {
                            $0 { $0["_id"] { $0[.gte] = range.min } }
                            $0 { $0["_id"] { $0[.lte] = range.max } }
                        }
                    }
                }
            },
            against: self.database)

        let _:Mongo.Deletions = try response.deletions()
    }
}
