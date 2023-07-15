import BSONDecoding
import BSONEncoding

extension SymbolGraph
{
    @frozen public
    struct Node:Equatable, Sendable
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
extension SymbolGraph.Node
{
    public mutating
    func push(_ extension:__owned SymbolGraph.Extension) -> Int
    {
        defer { self.extensions.append(`extension`) }
        return self.extensions.endIndex
    }
}
extension SymbolGraph.Node
{
    @frozen public
    enum CodingKey:String
    {
        case extensions = "E"
        case decl = "V"
    }
}
extension SymbolGraph.Node:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.decl] = self.decl
        bson[.extensions] = self.extensions.isEmpty ? nil : self.extensions
    }
}
extension SymbolGraph.Node:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            extensions: try bson[.extensions]?.decode() ?? [],
            decl: try bson[.decl]?.decode())
    }
}
