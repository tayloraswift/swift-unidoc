import BSON
import Symbols

extension SymbolGraph
{
    /// A declaration node holds an optional ``Decl`` and a list of ``Extension``s.
    /// It abstracts over local and external declarations.
    @frozen public
    struct DeclNode:Equatable, Sendable
    {
        public
        var extensions:[Extension]
        public
        var exporters:[Int]
        public
        var decl:Decl?

        @inlinable public
        init(extensions:[Extension] = [], exporters:[Int] = [], decl:Decl? = nil)
        {
            self.extensions = extensions
            self.exporters = exporters
            self.decl = decl
        }
    }
}
extension SymbolGraph.DeclNode:SymbolGraphNode
{
    public
    typealias Plane = SymbolGraph.DeclPlane
    public
    typealias ID = Symbol.Decl

    /// A declaration node is a citizen of its symbol graph if and only if ``decl`` is non-nil.
    @inlinable public
    var isCitizen:Bool { self.decl != nil }
}
extension SymbolGraph.DeclNode
{
    public mutating
    func push(_ extension:__owned SymbolGraph.Extension) -> Int
    {
        defer { self.extensions.append(`extension`) }
        return self.extensions.endIndex
    }
}
extension SymbolGraph.DeclNode
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case extensions = "E"
        case exporters = "X"
        case decl = "V"
    }
}
extension SymbolGraph.DeclNode:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.decl] = self.decl
        bson[.exporters] = SymbolGraph.Buffer16.init(elidingEmpty: self.exporters)
        bson[.extensions] = self.extensions.isEmpty ? nil : self.extensions
    }
}
extension SymbolGraph.DeclNode:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(
            extensions: try bson[.extensions]?.decode() ?? [],
            exporters: try bson[.exporters]?.decode(
                as: SymbolGraph.Buffer16.self, with: \.elements) ?? [],
            decl: try bson[.decl]?.decode())
    }
}
