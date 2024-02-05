import BSON

extension Unidoc
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
extension Unidoc.Census
{
    public
    enum CodingKey:String, Sendable
    {
        case unweighted = "U"
        case weighted = "W"
    }
}
extension Unidoc.Census:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.unweighted] = self.unweighted
        bson[.weighted] = self.weighted
    }
}
extension Unidoc.Census:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(
            unweighted: try bson[.unweighted].decode(),
            weighted: try bson[.weighted].decode())
    }
}
