import BSON
import Unidoc

extension Unidoc.Scalar:BSONRepresentable
{
    @inlinable public
    var bson:BSON.Identifier
    {
        .init(self.package.bits, self.version.bits, .init(bitPattern: self.citizen))
    }
    @inlinable public
    init(_ bson:BSON.Identifier)
    {
        self.init(
            package: .init(bits: bson.timestamp),
            version: .init(bits: bson.middle),
            citizen: .init(bitPattern: bson.low))
    }
}
extension Unidoc.Scalar:BSONDecodable, BSONEncodable
{
}
