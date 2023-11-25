import BSONDecoding
import BSONEncoding
import MongoQL
import SemanticVersions
import SymbolGraphs

@frozen public
struct PackageSubscription
{
    /// Uniquely identifies a subscription of a package edition to a package.
    public
    let id:ID

    /// The lower bound of the consumer’s version requirement.
    public
    let from:PatchVersion
    /// The upper bound of the consumer’s version requirement, or nil if it has an exact
    /// version requirement. The upper bound is exclusive.
    public
    let till:PatchVersion?

    @inlinable public
    init(id:ID, from:PatchVersion, till:PatchVersion?)
    {
        self.id = id
        self.from = from
        self.till = till
    }
}
extension PackageSubscription:MongoMasterCodingModel
{
    public
    enum CodingKey:String, Sendable
    {
        case id = "_id"
        case from = "L"
        case till = "U"
    }
}
extension PackageSubscription:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.from] = self.from
        bson[.till] = self.till
    }
}
extension PackageSubscription:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(id: try bson[.id].decode(),
            from: try bson[.from].decode(),
            till: try bson[.till]?.decode())
    }
}
