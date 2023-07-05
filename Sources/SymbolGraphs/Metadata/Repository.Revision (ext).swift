
import BSONDecoding
import BSONEncoding
import ModuleGraphs

extension Repository.Revision:BSONEncodable
{
    public
    func encode(to field:inout BSON.Field)
    {
        let view:BSON.BinaryView<Self> = .init(subtype: .generic, slice: self)
        view.encode(to: &field)
    }
}
extension Repository.Revision:BSONDecodable, BSONBinaryViewDecodable
{
    @inlinable public
    init(bson:BSON.BinaryView<some RandomAccessCollection<UInt8>>) throws
    {
        try bson.subtype.expect(.generic)

        if  let revision:Self = .init(bytes: bson.slice)
        {
            self = revision
        }
        else
        {
            throw BSON.ShapeError.init(invalid: bson.slice.count, expected: .length(20))
        }
    }
}
