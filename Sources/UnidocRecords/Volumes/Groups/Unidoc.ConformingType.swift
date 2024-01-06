import BSON
import Signatures
import SymbolGraphs

extension Unidoc
{
    @frozen public
    struct ConformingType:Equatable, Sendable
    {
        public
        let id:Unidoc.Scalar
        public
        let constraints:[GenericConstraint<Unidoc.Scalar?>]

        @inlinable public
        init(id:Unidoc.Scalar, where constraints:[GenericConstraint<Unidoc.Scalar?>] = [])
        {
            self.id = id
            self.constraints = constraints
        }
    }
}
extension Unidoc.ConformingType
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case id = "i"
        //  Non-optional, because we expect to encode unconditional conformances separately.
        case constraints = "g"
    }
}
extension Unidoc.ConformingType:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.constraints] = self.constraints
    }
}
extension Unidoc.ConformingType:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(id: try bson[.id].decode(), where: try bson[.constraints].decode())
    }
}
