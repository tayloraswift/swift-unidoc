import BSON
import SymbolGraphs
import Unidoc

extension Unidoc.Scalar
{
    @inlinable public
    var plane:SymbolGraph.Plane? { .of(self.citizen) }
}
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
