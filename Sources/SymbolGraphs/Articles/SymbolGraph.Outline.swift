
import BSONDecoding
import BSONEncoding
import Sources

extension SymbolGraph
{
    @frozen public
    struct Outline:Equatable, Hashable, Sendable
    {
        public
        let referent:Referent
        public
        let text:String

        @inlinable public
        init(referent:Referent, text:String)
        {
            self.referent = referent
            self.text = text
        }
    }
}
extension SymbolGraph.Outline
{
    public
    enum CodingKeys:String
    {
        case location = "L"
        case scalar = "R"
        case `self` = "S"
        case text = "T"
    }
}
extension SymbolGraph.Outline:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKeys>)
    {
        bson[.text] = self.text

        switch self.referent
        {
        case .scalar(let scalar):
            bson[.scalar] = scalar

        case .vector(let scalar, self: let heir):
            bson[.scalar] = scalar
            bson[.self] = heir

        case .unresolved(let location):
            bson[.location] = location
        }
    }
}
extension SymbolGraph.Outline:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>) throws
    {
        let referent:SymbolGraph.Outline.Referent

        if      let scalar:Int32 = try bson[.scalar]?.decode()
        {
            if  let heir:Int32 = try bson[.self]?.decode()
            {
                referent = .vector(scalar, self: heir)
            }
            else
            {
                referent = .scalar(scalar)
            }
        }
        else
        {
            referent = .unresolved(try bson[.location]?.decode())
        }

        self.init(referent: referent, text: try bson[.text].decode())
    }
}
