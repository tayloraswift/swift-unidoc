
import BSONDecoding
import BSONEncoding
import Sources

extension SymbolGraph
{
    @frozen public
    enum Outline:Equatable, Hashable, Sendable
    {
        case scalar(Int32, text:String)
        case vector(Int32, self:Int32, text:String)
        case unresolved(Unresolved)
    }
}
extension SymbolGraph.Outline
{
    public
    enum CodingKey:String
    {
        case unresolved_doc = "D"
        case unresolved_ucf = "U"
        case unresolved_unidocV3 = "C"

        case location = "L"
        case scalar = "R"
        case `self` = "S"
        case text = "T"
    }
}
extension SymbolGraph.Outline:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        switch self
        {
        case .scalar(let scalar, text: let text):
            bson[.scalar] = scalar
            bson[.text] = text

        case .vector(let scalar, self: let heir, text: let text):
            bson[.scalar] = scalar
            bson[.self] = heir
            bson[.text] = text

        case .unresolved(let self):
            bson[.location] = self.location

            switch self.type
            {
            case .doc:      bson[.unresolved_doc] = self.link
            case .ucf:      bson[.unresolved_ucf] = self.link
            case .unidocV3: bson[.unresolved_unidocV3] = self.link
            }
        }
    }
}
extension SymbolGraph.Outline:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        if  let scalar:Int32 = try bson[.scalar]?.decode()
        {
            let text:String = try bson[.text].decode()

            if  let heir:Int32 = try bson[.self]?.decode()
            {
                self = .vector(scalar, self: heir, text: text)
            }
            else
            {
                self = .scalar(scalar, text: text)
            }

            return
        }

        let type:Unresolved.LinkType
        let link:String

        if  let text:String = try bson[.unresolved_doc]?.decode()
        {
            type = .doc
            link = text
        }
        else if
            let text:String = try bson[.unresolved_ucf]?.decode()
        {
            type = .ucf
            link = text
        }
        else
        {
            type = .unidocV3
            link = try bson[.unresolved_unidocV3].decode()
        }

        self = .unresolved(.init(
            link: link,
            type: type,
            location: try bson[.location]?.decode()))
    }
}
