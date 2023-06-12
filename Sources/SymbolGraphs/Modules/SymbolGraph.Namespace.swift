import BSONDecoding
import BSONEncoding

extension SymbolGraph
{
    @frozen public
    struct Namespace:Equatable, Sendable
    {
        /// A range of addresses containing scalars that share this namespace.
        public
        let range:ClosedRange<Int32>
        /// The index of the namespace module.
        public
        let index:Int

        @inlinable public
        init(range:ClosedRange<Int32>, index:Int)
        {
            self.range = range
            self.index = index
        }
    }
}
extension SymbolGraph.Namespace
{
    @frozen public
    enum CodingKeys:String
    {
        case index = "I"
        case first = "F"
        case last = "L"
    }
}
extension SymbolGraph.Namespace:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKeys>)
    {
        bson[.index] = self.index
        bson[.first] = self.range.first
        bson[.last] = self.range.last
    }
}
extension SymbolGraph.Namespace:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            range: try bson[.first].decode() ... bson[.last].decode(),
            index: try bson[.index].decode())
    }
}
