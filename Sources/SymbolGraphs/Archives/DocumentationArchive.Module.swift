import BSONDecoding
import BSONEncoding
import ModuleGraphs

extension DocumentationArchive
{
    @frozen public
    struct Module:Equatable, Sendable
    {
        /// Information about the target associated with this module.
        public
        let target:TargetNode

        /// This module’s binary markdown documentation, if it has any.
        public
        var article:MarkdownArticle?

        @inlinable public
        init(target:TargetNode)
        {
            self.target = target
            self.article = nil
        }
    }
}
extension DocumentationArchive.Module:Identifiable
{
    @inlinable public
    var id:ModuleIdentifier
    {
        self.target.id
    }
}
extension DocumentationArchive.Module
{
    @frozen public
    enum CodingKeys:String
    {
        case article = "A"
        case target = "T"
    }
}
extension DocumentationArchive.Module:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKeys>)
    {
        bson[.target] = self.target
        bson[.article] = self.article
    }
}
extension DocumentationArchive.Module:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(target: try bson[.target].decode())
        self.article = try bson[.article]?.decode()
    }
}
