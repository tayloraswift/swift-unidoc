import BSON

extension Unidoc
{
    @frozen public
    struct Edge<Point>:Equatable, Hashable, Sendable
        where   Point:Equatable,
                Point:Hashable,
                Point:Sendable,
                Point:BSONEncodable,
                Point:BSONDecodable
    {
        public
        let source:Point
        public
        let target:Point

        @inlinable
        init(source:Point, target:Point)
        {
            self.source = source
            self.target = target
        }
    }
}
extension Unidoc.Edge
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case source = "s"
        case target = "t"
    }
}
extension Unidoc.Edge:BSONDocumentEncodable
{
    @inlinable public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.source] = self.source
        bson[.target] = self.target
    }
}
extension Unidoc.Edge:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(
            source: try bson[.source].decode(),
            target: try bson[.target].decode())
    }
}
