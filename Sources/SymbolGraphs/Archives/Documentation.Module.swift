import BSONDecoding
import BSONEncoding
import ModuleGraphs

extension Documentation
{
    @frozen public
    struct Module:Equatable, Sendable
    {
        public
        let stacked:ModuleInfo

        /// This module’s binary markdown documentation, if it has any.
        public
        var article:MarkdownArticle?

        @inlinable public
        init(stacked:ModuleInfo)
        {
            self.stacked = stacked
            self.article = nil
        }
    }
}
extension Documentation.Module:Identifiable
{
    @inlinable public
    var id:ModuleIdentifier
    {
        self.stacked.id
    }
}
extension Documentation.Module
{
    @frozen public
    enum CodingKeys:String
    {
        case article = "A"
        case stacked = "M"
    }
}
extension Documentation.Module:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKeys>)
    {
        bson[.stacked] = self.stacked
        bson[.article] = self.article
    }
}
extension Documentation.Module:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(stacked: try bson[.stacked].decode())
        self.article = try bson[.article]?.decode()
    }
}
