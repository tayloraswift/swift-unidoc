import BSON
import Unidoc

extension Unidoc
{
    @frozen public
    enum Outline:Equatable, Sendable
    {
        case file(line:Int?, Unidoc.Scalar)
        /// An external web link. The string does not contain the URL scheme.
        case link(https:String, safe:Bool)
        case path(String, [Unidoc.Scalar])
        case text(String)
    }
}
extension Unidoc.Outline
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case file_line = "L"
        case link_safe = "H"
        case link_url = "U"
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
        case .link(https: let url, let safe):
            bson[.link_safe] = safe ? true : nil
            bson[.link_url] = url

        case .file(line: let number, let file):
            bson[.file_line] = number
            bson[.scalars] = [file]

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
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        if  let display:String = try bson[.display]?.decode()
        {
            switch try bson[.scalars]?.decode(to: [Unidoc.Scalar].self)
            {
            case let scalars?:  self = .path(display, scalars)
            case nil:           self = .text(display)
            }
        }
        else if
            let url:String = try bson[.link_url]?.decode()
        {
            self = .link(https: url, safe: try bson[.link_safe]?.decode() ?? false)
        }
        else
        {
            let id:Unidoc.Scalar = try bson[.scalars].decode
            {
                try $0.shape.expect(length: 1)
                return try $0[0].decode()
            }

            self = .file(line: try bson[.file_line]?.decode(), id)
        }
    }
}
