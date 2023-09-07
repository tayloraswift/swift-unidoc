
import BSONDecoding
import BSONEncoding
import ModuleGraphs

extension Repository.Revision:BSONEncodable
{
    public
    func encode(to field:inout BSON.Field)
    {
        switch self
        {
        case .sha1(let hash):   hash.encode(to: &field)
        }
    }
}
extension Repository.Revision:BSONDecodable, BSONBinaryViewDecodable
{
    @inlinable public
    init(bson:BSON.BinaryView<some RandomAccessCollection<UInt8>>) throws
    {
        self = .sha1(try .init(bson: bson))
    }
}
