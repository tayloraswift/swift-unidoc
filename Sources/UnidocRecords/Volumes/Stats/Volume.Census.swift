import BSONDecoding
import BSONEncoding

extension Volume
{
    @frozen public
    struct Census:Equatable, Sendable
    {
        public
        var unweighted:Stats
        public
        var weighted:Stats

        @inlinable public
        init(unweighted:Stats = .init(), weighted:Stats = .init())
        {
            self.unweighted = unweighted
            self.weighted = weighted
        }
    }
}
extension Volume.Census
{
    public
    enum CodingKey:String, Sendable
    {
        case unweighted = "U"
        case weighted = "W"
    }
}
extension Volume.Census:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.unweighted] = self.unweighted
        bson[.weighted] = self.weighted
    }
}
extension Volume.Census:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            unweighted: try bson[.unweighted].decode(),
            weighted: try bson[.weighted].decode())
    }
}
