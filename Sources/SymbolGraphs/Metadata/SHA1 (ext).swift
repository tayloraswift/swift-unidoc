import BSON
import SHA1

extension SHA1:BSONBinaryEncodable
{
    public
    func encode(to bson:inout BSON.BinaryEncoder)
    {
        bson += self
    }
}
extension SHA1:BSONBinaryDecodable
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
            throw BSON.ShapeError.init(invalid: bson.bytes.count, expected: .length(20))
        }
    }
}
