import BSONDecoding
import BSONEncoding
import ModuleGraphs

extension DocumentationArchive
{
    @frozen public
    struct Module:Equatable, Sendable
    {
        public
        let stacked:ModuleStack

        /// This module’s binary markdown documentation, if it has any.
        public
        var article:MarkdownArticle?

        @inlinable public
        init(stacked:ModuleStack)
        {
            self.stacked = stacked
            self.article = nil
        }
    }
}
extension DocumentationArchive.Module:Identifiable
{
    @inlinable public
    var id:ModuleIdentifier
    {
        self.stacked.id
    }
}
extension DocumentationArchive.Module
{
    @frozen public
    enum CodingKeys:String
    {
        case article = "A"
        case stacked = "M"
    }
}
extension DocumentationArchive.Module:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKeys>)
    {
        bson[.stacked] = self.stacked
        bson[.article] = self.article
    }
}
extension DocumentationArchive.Module:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(stacked: try bson[.stacked].decode())
        self.article = try bson[.article]?.decode()
    }
}
