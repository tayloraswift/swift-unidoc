
import BSONDecoding
import BSONEncoding
import ModuleGraphs
import SHA1

extension Repository.Revision:BSONEncodable
{
    public
    func encode(to field:inout BSON.Field)
    {
        switch self
        {
        case .sha1(let hash):
            let view:BSON.BinaryView<SHA1> = .init(subtype: .generic, slice: hash)
                view.encode(to: &field)
        }
    }
}
extension Repository.Revision:BSONDecodable, BSONBinaryViewDecodable
{
    @inlinable public
    init(bson:BSON.BinaryView<some RandomAccessCollection<UInt8>>) throws
    {
        try bson.subtype.expect(.generic)

        if  let hash:SHA1 = .copy(from: bson.slice)
        {
            self = .sha1(hash)
        }
        else
        {
            throw BSON.ShapeError.init(invalid: bson.slice.count, expected: .length(20))
        }
    }
}
