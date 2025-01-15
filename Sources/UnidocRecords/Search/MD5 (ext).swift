import BSON
import MD5

extension MD5:@retroactive BSONBinaryEncodable
{
    @inlinable public
    func encode(to bson:inout BSON.BinaryEncoder)
    {
        bson.subtype = .md5
        bson += self
    }
}
extension MD5:@retroactive BSONBinaryDecodable
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
            throw BSON.BinaryShapeError.init(invalid: bson.bytes.count, expected: .size(16))
        }
    }
}
