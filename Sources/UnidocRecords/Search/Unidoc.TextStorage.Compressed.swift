import BSON

extension Unidoc.TextStorage
{
    @frozen public
    struct Compressed:Equatable, Sendable
    {
        public
        var bytes:ArraySlice<UInt8>

        @inlinable public
        init(bytes:ArraySlice<UInt8>)
        {
            self.bytes = bytes
        }
    }
}
extension Unidoc.TextStorage.Compressed:BSONBinaryEncodable
{
    @inlinable public
    func encode(to bson:inout BSON.BinaryEncoder)
    {
        //  Do NOT use `compressed` subtype here. That has a special meaning to MongoDB, and
        //  newer versions of `mongod` will reject it.
        bson += self.bytes
    }
}
extension Unidoc.TextStorage.Compressed:BSONBinaryDecodable
{
    @inlinable public
    init(bson:BSON.BinaryDecoder)
    {
        self.init(bytes: bson.bytes)
    }
}
