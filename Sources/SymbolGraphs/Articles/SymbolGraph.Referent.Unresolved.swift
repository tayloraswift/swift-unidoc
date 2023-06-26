import BSONDecoding
import BSONEncoding
import Sources

extension SymbolGraph.Referent
{
    @frozen public
    struct Unresolved:Equatable, Hashable, Sendable
    {
        public
        let expression:String
        public
        let location:SourceLocation<Int32>?

        @inlinable public
        init(_ expression:String, location:SourceLocation<Int32>?)
        {
            self.expression = expression
            self.location = location
        }
    }
}
extension SymbolGraph.Referent.Unresolved
{
    public
    enum CodingKeys:String
    {
        case expression = "E"
        case location = "S"
    }
}
extension SymbolGraph.Referent.Unresolved:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKeys>)
    {
        bson[.expression] = self.expression
        bson[.location] = self.location
    }
}
extension SymbolGraph.Referent.Unresolved:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(try bson[.expression].decode(), location: try bson[.location]?.decode())
    }
}
