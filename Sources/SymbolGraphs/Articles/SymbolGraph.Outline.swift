
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
        case codelink(String, SourceLocation<Int32>?)
        case doclink(String, SourceLocation<Int32>?)
    }
}
extension SymbolGraph.Outline
{
    public
    enum CodingKey:String
    {
        case codelink = "C"
        case doclink = "D"
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
        case .codelink(let expression, let location):
            bson[.codelink] = expression
            bson[.location] = location

        case .doclink(let expression, let location):
            bson[.doclink] = expression
            bson[.location] = location

        case .scalar(let scalar, text: let text):
            bson[.scalar] = scalar
            bson[.text] = text

        case .vector(let scalar, self: let heir, text: let text):
            bson[.scalar] = scalar
            bson[.self] = heir
            bson[.text] = text
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

        let location:SourceLocation<Int32>? = try bson[.location]?.decode()

        if  let expression:String = try bson[.codelink]?.decode()
        {
            self = .codelink(expression, location)
        }
        else
        {
            let expression:String = try bson[.doclink].decode()
            self = .doclink(expression, location)
        }
    }
}
