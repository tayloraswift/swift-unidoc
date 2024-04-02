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
extension Unidoc.TextStorage.Compressed:BSONEncodable
{
    @inlinable public
    func encode(to bson:inout BSON.FieldEncoder)
    {
        //  Do NOT use `compressed` here. That has a special meaning to MongoDB, and newer
        //  versions of `mongod` will reject it.
        let binary:BSON.BinaryView<ArraySlice<UInt8>> = .init(subtype: .generic,
            bytes: self.bytes)
        binary.encode(to: &bson)
    }
}
extension Unidoc.TextStorage.Compressed:BSONDecodable, BSONBinaryViewDecodable
{
    @inlinable public
    init(bson:BSON.BinaryView<ArraySlice<UInt8>>)
    {
        self.bytes = bson.bytes
    }
}
