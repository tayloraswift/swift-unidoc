import BSON
import MD5

extension MD5:BSONBinaryEncodable
{
    @inlinable public
    func encode(to bson:inout BSON.BinaryEncoder)
    {
        bson.subtype = .md5
        bson += self
    }
}
extension MD5:BSONBinaryDecodable
{
    @inlinable public
    init(bson:BSON.BinaryDecoder) throws
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
