import BSONDecoding
import BSONEncoding
import MongoQL

extension PackageSubscription
{
    public
    struct ID:Equatable, Hashable, Sendable
    {
        /// The coordinate of the upstream package being depended on.
        public
        let dependency:Int32
        /// The coordinate of the consumer package.
        public
        let dependent:Int32
        /// The version of ``dependent`` that depends on ``dependency``.
        public
        let version:Int32

        @inlinable public
        init(dependency:Int32,
            dependent:Int32,
            version:Int32)
        {
            self.dependency = dependency
            self.dependent = dependent
            self.version = version
        }
    }
}
extension PackageSubscription.ID:MongoMasterCodingModel
{
    /// At first-glance, encoding the `_id` as three broken-down components is inefficient,
    /// but it means we can build sub-indexes on the individual components instead of having
    /// to duplicate information in the `_id` field.
    public
    enum CodingKey:String
    {
        case dependency = "D"
        case dependent = "P"
        case version = "V"
    }
}
extension PackageSubscription.ID:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.dependency] = self.dependency
        bson[.dependent] = self.dependent
        bson[.version] = self.version
    }
}
extension PackageSubscription.ID:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            dependency: try bson[.dependency].decode(),
            dependent: try bson[.dependent].decode(),
            version: try bson[.version].decode())
    }
}
