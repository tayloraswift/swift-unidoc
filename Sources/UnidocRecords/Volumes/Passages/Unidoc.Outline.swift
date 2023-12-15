import BSON
import Unidoc

extension Unidoc
{
    @frozen public
    enum Outline:Equatable, Sendable
    {
        case path(String, [Unidoc.Scalar])
        case text(String)
    }
}
extension Unidoc.Outline
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case display = "T"
        case scalars = "s"
    }
}
extension Unidoc.Outline:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
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
extension Unidoc.Outline:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        let display:String = try bson[.display].decode()
        switch try bson[.scalars]?.decode(to: [Unidoc.Scalar].self)
        {
        case let scalars?:  self = .path(display, scalars)
        case nil:           self = .text(display)
        }
    }
}