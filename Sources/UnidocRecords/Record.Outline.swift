import BSONDecoding
import BSONEncoding
import Unidoc

extension Record
{
    @frozen public
    enum Outline:Equatable, Sendable
    {
        case path(String, [Unidoc.Scalar])
        case text(String)
    }
}
extension Record.Outline
{
    public
    enum CodingKeys:String
    {
        case display = "T"
        case scalars = "S"
    }
}
extension Record.Outline:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKeys>)
    {
        switch self
        {
        case .path(let string, let scalars):
            bson[.scalars] = scalars
            bson[.display] = string

        case .text(let string):
            bson[.display] = string
        }
    }
}
extension Record.Outline:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>) throws
    {
        let display:String = try bson[.display].decode()
        switch try bson[.scalars]?.decode(to: [Unidoc.Scalar].self)
        {
        case let scalars?:  self = .path(display, scalars)
        case nil:           self = .text(display)
        }
    }
}
