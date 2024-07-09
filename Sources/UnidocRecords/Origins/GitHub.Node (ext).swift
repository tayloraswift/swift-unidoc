import BSON
import GitHubAPI

extension GitHub.Node:BSONBinaryEncodable
{
    /// Encodes the node identifier as a binary array, to exempt it from string collation.
    @inlinable public
    func encode(to bson:inout BSON.BinaryEncoder)
    {
        bson.subtype = .custom(code: 0x80)
        bson += self.rawValue.utf8
    }
}
extension GitHub.Node:BSONBinaryDecodable
{
    @inlinable public
    init(bson:BSON.BinaryDecoder) throws
    {
        self.init(rawValue: .init(decoding: bson.bytes, as: Unicode.ASCII.self))
    }
}
