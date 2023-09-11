import BSONDecoding
import BSONEncoding
import SHA1

extension SHA1:BSONEncodable
{
    public
    func encode(to field:inout BSON.Field)
    {
        let view:BSON.BinaryView<SHA1> = .init(subtype: .generic, slice: self)
            view.encode(to: &field)
    }
}
extension SHA1:BSONDecodable, BSONBinaryViewDecodable
{
    @inlinable public
    init(bson:BSON.BinaryView<some RandomAccessCollection<UInt8>>) throws
    {
        try bson.subtype.expect(.generic)

        if  let hash:SHA1 = .copy(from: bson.slice)
        {
            self = hash
        }
        else
        {
            throw BSON.ShapeError.init(invalid: bson.slice.count, expected: .length(20))
        }
    }
}
