import BSON
import SHA1

extension SHA1:BSONEncodable
{
    public
    func encode(to field:inout BSON.FieldEncoder)
    {
        let view:BSON.BinaryView<SHA1> = .init(subtype: .generic, bytes: self)
            view.encode(to: &field)
    }
}
extension SHA1:BSONDecodable, BSONBinaryViewDecodable
{
    @inlinable public
    init(bson:BSON.BinaryView<ArraySlice<UInt8>>) throws
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
