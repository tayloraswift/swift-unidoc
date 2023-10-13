import BSONDecoding
import BSONEncoding
import MongoDB

protocol DatabaseCollectionCapped:DatabaseCollection
{
    static
    var capacity:(bytes:Int, count:Int?) { get }
}
extension DatabaseCollectionCapped
{
    private
    func setupCapacity(with session:Mongo.Session) async throws
    {
        do
        {
            try await session.run(
                command: Mongo.Modify<Mongo.Collection>.init(Self.name)
                {
                    $0[.cappedSize] = Self.capacity.bytes
                    $0[.cappedMax] = Self.capacity.count
                },
                against: self.database)
        }
        catch is Mongo.NamespaceError
        {
            try await session.run(
                command: Mongo.Create<Mongo.Collection>.init(Self.name)
                {
                    $0[.cap] = (size: Self.capacity.bytes, max: Self.capacity.count)
                },
                against: self.database)
        }
    }

    func setup(with session:Mongo.Session) async throws
    {
        try await self.setupCapacity(with: session)
        try await self.setupIndexes(with: session)
    }
}
extension DatabaseCollectionCapped
{
    func find<Decodable>(_:Decodable.Type = Decodable.self,
        last count:Int,
        with session:Mongo.Session) async throws -> [Decodable]
        where Decodable:BSONDocumentDecodable
    {
        try await session.run(
            command: Mongo.Find<Mongo.SingleBatch<Decodable>>.init(Self.name,
                limit: count)
            {
                $0[.sort] = .init { $0[.natural] = (-) }
            },
            against: self.database)
    }
}
