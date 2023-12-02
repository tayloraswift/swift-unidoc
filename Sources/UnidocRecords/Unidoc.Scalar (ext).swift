import BSON
import Unidoc

extension Unidoc.Scalar:BSONRepresentable
{
    @inlinable public
    var bson:BSON.Identifier
    {
        .init(
            .init(bitPattern: self.package),
            .init(bitPattern: self.version),
            .init(bitPattern: self.citizen))
    }
    @inlinable public
    init(_ bson:BSON.Identifier)
    {
        self.init(
            package: .init(bitPattern: bson.timestamp),
            version: .init(bitPattern: bson.middle),
            citizen: .init(bitPattern: bson.low))
    }
}
extension Unidoc.Scalar:BSONDecodable, BSONEncodable
{
}
