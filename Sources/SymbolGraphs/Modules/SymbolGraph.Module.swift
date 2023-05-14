import BSONDecoding
import BSONEncoding
import PackageGraphs

extension SymbolGraph
{
    @frozen public
    struct Module:Equatable, Sendable
    {
        /// Information about the target associated with this module.
        public
        let target:TargetNode

        /// This module’s binary markdown documentation, if it has any.
        public
        var article:Article?

        @inlinable public
        init(target:TargetNode)
        {
            self.target = target
            self.article = nil
        }
    }
}
extension SymbolGraph.Module:Identifiable
{
    @inlinable public
    var id:ModuleIdentifier
    {
        self.target.id
    }
}
extension SymbolGraph.Module
{
    @frozen public
    enum CodingKeys:String
    {
        case article = "A"
        case target = "T"
    }
}
extension SymbolGraph.Module:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKeys>)
    {
        bson[.target] = self.target
        bson[.article] = self.article
    }
}
extension SymbolGraph.Module:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(target: try bson[.target].decode())
        self.article = try bson[.article]?.decode()
    }
}
