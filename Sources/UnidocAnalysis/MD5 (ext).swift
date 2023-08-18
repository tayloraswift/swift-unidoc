import BSONDecoding
import BSONEncoding
import MD5

extension MD5:BSONEncodable
{
    @inlinable public
    func encode(to bson:inout BSON.Field)
    {
        BSON.BinaryView<Self>.init(subtype: .md5, slice: self).encode(to: &bson)
    }
}
extension MD5:BSONDecodable, BSONBinaryViewDecodable
{
    @inlinable public
    init(bson:BSON.BinaryView<some RandomAccessCollection<UInt8>>) throws
    {
        try bson.subtype.expect(.md5)

        if  let hash:Self = .copy(from: bson.slice)
        {
            self = hash
        }
        else
        {
            throw BSON.ShapeError.init(invalid: bson.slice.count, expected: .length(16))
        }
    }
}
