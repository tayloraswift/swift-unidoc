import BSON
import MD5

extension MD5:BSONEncodable
{
    @inlinable public
    func encode(to bson:inout BSON.FieldEncoder)
    {
        BSON.BinaryView<Self>.init(subtype: .md5, bytes: self).encode(to: &bson)
    }
}
extension MD5:BSONDecodable, BSONBinaryViewDecodable
{
    @inlinable public
    init(bson:BSON.BinaryView<ArraySlice<UInt8>>) throws
    {
        try bson.subtype.expect(.md5)

        if  let hash:Self = .copy(from: bson.bytes)
        {
            self = hash
        }
        else
        {
            throw BSON.ShapeError.init(invalid: bson.bytes.count, expected: .length(16))
        }
    }
}
