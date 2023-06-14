import BSONDecoding
import BSONEncoding

extension SymbolGraph
{
    @frozen public
    struct Articles:Equatable
    {
        @usableFromInline internal
        var table:Table<Article<String>>

        @inlinable internal
        init(table:Table<Article<String>> = [])
        {
            self.table = table
        }
    }
}
extension SymbolGraph.Articles
{
    @inlinable internal mutating
    func append(_ article:SymbolGraph.Article<String>)
    {
        _ = self.table.append(article)
    }
}
extension SymbolGraph.Articles:RandomAccessCollection
{
    @inlinable public
    var startIndex:Int32
    {
        .min | self.table.startIndex
    }
    @inlinable public
    var endIndex:Int32
    {
        .min | self.table.endIndex
    }
    @inlinable public
    subscript(index:Int32) -> SymbolGraph.Article<String>
    {
        _read
        {
            yield  self.table[index & .max]
        }
        _modify
        {
            yield &self.table[index & .max]
        }
    }
}
extension SymbolGraph.Articles:BSONEncodable
{
    public
    func encode(to field:inout BSON.Field)
    {
        self.table.encode(to: &field)
    }
}
extension SymbolGraph.Articles:BSONDecodable
{
    @inlinable public
    init(bson:BSON.AnyValue<some RandomAccessCollection<UInt8>>) throws
    {
        self.init(table: try .init(bson: bson))
    }
}
