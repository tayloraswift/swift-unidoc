import BSON

extension Unidoc.Stats
{
    @frozen public
    struct Coverage:Equatable, Sendable
    {
        /// Declarations with no documentation whatsoever.
        public
        var undocumented:Int
        /// Declarations with no documentation but have at least one documented relative.
        public
        var indirect:Int
        /// Declarations with documentation.
        public
        var direct:Int

        @inlinable public
        init(undocumented:Int, indirect:Int, direct:Int)
        {
            self.undocumented = undocumented
            self.indirect = indirect
            self.direct = direct
        }
    }
}
extension Unidoc.Stats.Coverage:ExpressibleByDictionaryLiteral
{
    @inlinable public
    init(dictionaryLiteral elements:(Never, Int)...)
    {
        self.init(undocumented: 0, indirect: 0, direct: 0)
    }
}
extension Unidoc.Stats.Coverage
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case undocumented = "U"
        case indirect = "I"
        case direct = "D"
    }
}
extension Unidoc.Stats.Coverage:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.undocumented] = self.undocumented != 0 ? self.undocumented : nil
        bson[.indirect] = self.indirect != 0 ? self.indirect : nil
        bson[.direct] = self.direct != 0 ? self.direct : nil
    }
}
extension Unidoc.Stats.Coverage:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            undocumented: try bson[.undocumented]?.decode() ?? 0,
            indirect: try bson[.indirect]?.decode() ?? 0,
            direct: try bson[.direct]?.decode() ?? 0)
    }
}
