import BSON
import SymbolGraphs
import Unidoc

extension Unidoc
{
    @frozen public
    enum Outline:Equatable, Sendable
    {
        /// A broken link, with optional fallback text.
        case fallback(String?)
        /// A same-page link, encoded as a URL fragment without the hashtag (`#`) prefix.
        case fragment(String)
        /// A bare scalar link with no accompanying outline text. The `line` parameter
        /// is only meaningful when the vertex is a file.
        case bare(line:Int?, Unidoc.Scalar)
        /// A vector link with accompanying outline text specifying the visual presentation of
        /// the link, along with an optional URL fragment.
        case path(SymbolGraph.OutlineText, [Unidoc.Scalar])
        /// An external web link.
        case url(String, safe:Bool)
    }
}
extension Unidoc.Outline
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case file_line = "L"
        case link_safe = "H"
        case link_url = "V"

        //  DEPRECATED, use ``link_url`` instead.
        case link_https = "U"

        case fragment = "F"
        case display = "T"
        case scalars = "s"
        case scalar = "r"
    }
}
extension Unidoc.Outline:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        switch self
        {
        case .fallback(let text):
            bson[.display] = text

        case .fragment(let display):
            bson[.fragment] = display

        case .bare(line: let number, let id):
            bson[.file_line] = number
            bson[.scalar] = id

        case .path(let display, let vector):
            if  vector.count == 1
            {
                bson[.scalar] = vector[0]
            }
            else
            {
                bson[.scalars] = vector
            }

            bson[.display] = display

        case .url(let url, safe: let safe):
            bson[.link_safe] = safe ? true : nil
            bson[.link_url] = url
        }
    }
}
extension Unidoc.Outline:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        if  let text:String = try bson[.display]?.decode()
        {
            if  let id:Unidoc.Scalar = try bson[.scalar]?.decode()
            {
                self = .path(SymbolGraph.OutlineText.init(text), [id])
            }
            else if
                let path:[Unidoc.Scalar] = try bson[.scalars]?.decode()
            {
                self = .path(SymbolGraph.OutlineText.init(text), path)
            }
            else
            {
                self = .fallback(text)
            }
        }
        else
        {
            /// Note: need to handle legacy array encoding
            let id:Unidoc.Scalar? = try bson[.scalar]?.decode() ?? bson[.scalars]?.decode
            {
                let first:Unidoc.Scalar = try $0[+].decode()
                try $0[+]?.decode(to: Never.self)
                return first
            }
            if  let id:Unidoc.Scalar
            {
                self = .bare(line: try bson[.file_line]?.decode(), id)
            }
            else if
                let text:String = try bson[.fragment]?.decode()
            {
                self = .fragment(text)
            }
            else if
                let url:String = try bson[.link_url]?.decode()
            {
                self = .url(url, safe: try bson[.link_safe]?.decode() ?? false)
            }
            else if
                let suffix:String = try bson[.link_https]?.decode()
            {
                self = .url("https://\(suffix)", safe: try bson[.link_safe]?.decode() ?? false)
            }
            else
            {
                self = .fallback(nil)
            }
        }
    }
}
