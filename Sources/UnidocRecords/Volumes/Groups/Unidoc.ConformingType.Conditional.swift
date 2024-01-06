import BSON
import Signatures
import SymbolGraphs

extension Unidoc.ConformingType
{
    @frozen public
    struct Conditional:Equatable, Sendable
    {
        @usableFromInline
        let id:Unidoc.Scalar
        @usableFromInline
        let constraints:[GenericConstraint<Unidoc.Scalar?>]

        @inlinable
        init(id:Unidoc.Scalar, where constraints:[GenericConstraint<Unidoc.Scalar?>])
        {
            self.id = id
            self.constraints = constraints
        }
    }
}
extension Unidoc.ConformingType.Conditional
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case id = "i"
        case constraints = "g"
    }
}
extension Unidoc.ConformingType.Conditional:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.constraints] = self.constraints
    }
}
extension Unidoc.ConformingType.Conditional:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(id: try bson[.id].decode(), where: try bson[.constraints].decode())
    }
}
