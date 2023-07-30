import BSONDecoding
import BSONEncoding
import ModuleGraphs

extension SymbolGraph
{
    @frozen public
    struct Culture:Equatable, Sendable
    {
        public
        let module:ModuleDetails

        /// The namespaces that contain this module’s scalars, if it declares any.
        /// The ranges must be contiguous and non-overlapping.
        public
        var namespaces:[SymbolGraph.Namespace]
        /// This module’s standalone articles, if it has any.
        public
        var articles:ClosedRange<Int32>?
        /// This module’s primary article, if it has one.
        public
        var article:Article?

        public
        var topics:[Topic]

        @inlinable public
        init(module:ModuleDetails)
        {
            self.module = module

            self.namespaces = []
            self.articles = nil
            self.article = nil
            self.topics = []
        }
    }
}
extension SymbolGraph.Culture:Identifiable
{
    @inlinable public
    var id:ModuleIdentifier
    {
        self.module.id
    }
}
extension SymbolGraph.Culture
{
    @inlinable public
    var decls:ClosedRange<Int32>?
    {
        if  let first:Int32 = self.namespaces.first?.range.first,
            let last:Int32 = self.namespaces.last?.range.last
        {
            return first ... last
        }
        else
        {
            return nil
        }
    }
}
extension SymbolGraph.Culture
{
    @frozen public
    enum CodingKey:String
    {
        case module = "M"

        case namespaces = "N"
        case articles_lower = "L"
        case articles_upper = "U"
        case article = "A"
        case topics = "T"
    }
}
extension SymbolGraph.Culture:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.module] = self.module

        bson[.namespaces] = self.namespaces.isEmpty ? nil : self.namespaces
        bson[.articles_lower] = self.articles?.lowerBound
        bson[.articles_upper] = self.articles?.upperBound
        bson[.article] = self.article
        bson[.topics] = self.topics.isEmpty ? nil : self.topics
    }
}
extension SymbolGraph.Culture:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(module: try bson[.module].decode())

        if  let lower:Int32 = try bson[.articles_lower]?.decode(),
            let upper:Int32 = try bson[.articles_upper]?.decode()
        {
            self.articles = upper < lower ? nil : lower ... upper
        }

        //  TODO: validate well-formedness of scalar ranges.
        self.namespaces = try bson[.namespaces]?.decode() ?? []
        self.article = try bson[.article]?.decode()
        self.topics = try bson[.topics]?.decode() ?? []
    }
}
