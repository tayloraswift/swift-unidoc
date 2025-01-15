import BSON
import SHA1

extension SHA1:@retroactive BSONBinaryEncodable
{
    public
    func encode(to bson:inout BSON.BinaryEncoder)
    {
        bson += self
    }
}
extension SHA1:@retroactive BSONBinaryDecodable
{
    @inlinable public
    init(bson:BSON.BinaryDecoder) throws
    {
        try bson.subtype.expect(.generic)

        if  let hash:SHA1 = .copy(from: bson.bytes)
        {
            self = hash
        }
        else
        {
            throw BSON.BinaryShapeError.init(invalid: bson.bytes.count, expected: .size(20))
        }
    }
}
