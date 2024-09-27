import BSON
import MarkdownABI
import Symbols

extension SymbolGraph
{
    @frozen public
    struct Culture:Equatable, Sendable
    {
        public
        let module:Module

        /// The namespaces that contain this module’s scalars, if it declares any.
        /// The ranges must be contiguous and non-overlapping.
        public
        var namespaces:[SymbolGraph.Namespace]
        /// Declarations this module re-exports, if any.
        public
        var reexports:[Int32]

        /// This module’s standalone articles, if it has any.
        public
        var articles:ClosedRange<Int32>?

        /// A custom headline to override the automatically-generated page title.
        public
        var headline:Markdown.Bytecode?
        /// This module’s primary article, if it has one.
        public
        var article:Article?

        @inlinable public
        init(module:Module)
        {
            self.module = module

            self.namespaces = []
            self.reexports = []
            self.articles = nil
            self.headline = nil
            self.article = nil
        }
    }
}
extension SymbolGraph.Culture:Identifiable
{
    @inlinable public
    var id:Symbol.Module
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
            first ... last
        }
        else
        {
            nil
        }
    }
}
extension SymbolGraph.Culture
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case module = "M"

        case namespaces = "N"
        case reexports = "X"
        case articles_lower = "L"
        case articles_upper = "U"
        case headline = "H"
        case article = "A"
    }
}
extension SymbolGraph.Culture:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.module] = self.module

        bson[.namespaces] = self.namespaces.isEmpty ? nil : self.namespaces
        bson[.reexports] = SymbolGraph.Buffer24.init(elidingEmpty: self.reexports)
        bson[.articles_lower] = self.articles?.lowerBound
        bson[.articles_upper] = self.articles?.upperBound
        bson[.headline] = self.headline
        bson[.article] = self.article
    }
}
extension SymbolGraph.Culture:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(module: try bson[.module].decode())

        if  let lower:Int32 = try bson[.articles_lower]?.decode(),
            let upper:Int32 = try bson[.articles_upper]?.decode()
        {
            self.articles = upper < lower ? nil : lower ... upper
        }

        //  TODO: validate well-formedness of scalar ranges.
        self.namespaces = try bson[.namespaces]?.decode() ?? []
        self.reexports = try bson[.reexports]?.decode(as: SymbolGraph.Buffer24.self,
            with: \.elements) ?? []
        self.headline = try bson[.headline]?.decode()
        self.article = try bson[.article]?.decode()
    }
}
