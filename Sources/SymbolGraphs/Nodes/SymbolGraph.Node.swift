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
        var scalar:Scalar?

        @inlinable public
        init(extensions:[Extension] = [], scalar:Scalar? = nil)
        {
            self.extensions = extensions
            self.scalar = scalar
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
    enum CodingKeys:String
    {
        case extensions = "E"
        case scalar = "V"
    }
}
extension SymbolGraph.Node:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKeys>)
    {
        bson[.scalar] = self.scalar
        bson[.extensions] = self.extensions.isEmpty ? nil : self.extensions
    }
}
extension SymbolGraph.Node:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            extensions: try bson[.extensions]?.decode() ?? [],
            scalar: try bson[.scalar]?.decode())
    }
}
