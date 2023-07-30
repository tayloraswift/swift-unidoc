import BSONDecoding
import BSONEncoding
import Symbols
import Unidoc

extension SymbolGraph
{
    @frozen public
    struct DeclNode:Equatable, Sendable
    {
        public
        var extensions:[Extension]
        public
        var decl:Decl?

        @inlinable public
        init(extensions:[Extension] = [], decl:Decl? = nil)
        {
            self.extensions = extensions
            self.decl = decl
        }
    }
}
extension SymbolGraph.DeclNode:SymbolGraphNode
{
    public
    typealias Plane = UnidocPlane.Decl
    public
    typealias ID = Symbol.Decl

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
    enum CodingKey:String
    {
        case extensions = "E"
        case decl = "V"
    }
}
extension SymbolGraph.DeclNode:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.decl] = self.decl
        bson[.extensions] = self.extensions.isEmpty ? nil : self.extensions
    }
}
extension SymbolGraph.DeclNode:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            extensions: try bson[.extensions]?.decode() ?? [],
            decl: try bson[.decl]?.decode())
    }
}
