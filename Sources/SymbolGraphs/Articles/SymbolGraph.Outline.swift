
import BSON
import Sources

extension SymbolGraph
{
    @frozen public
    enum Outline:Equatable, Hashable, Sendable
    {
        case vertex(Int32, text:String)
        case vector(Int32, self:Int32, text:String)
        case unresolved(Unresolved)
    }
}
//  These are only here to make it obvious these links do not contain a scheme.
extension SymbolGraph.Outline
{
    @inlinable public static
    func unresolved(doc link:String, location:SourceLocation<Int32>?) -> Self
    {
        .unresolved(.init(link: link, type: .doc, location: location))
    }

    @inlinable public static
    func unresolved(web link:String, location:SourceLocation<Int32>?) -> Self
    {
        .unresolved(.init(link: link, type: .web, location: location))
    }

    @inlinable public static
    func unresolved(ucf link:String, location:SourceLocation<Int32>?) -> Self
    {
        .unresolved(.init(link: link, type: .ucf, location: location))
    }
}
extension SymbolGraph.Outline
{
    public
    enum CodingKey:String, Sendable
    {
        case unresolved_doc = "D"
        case unresolved_web = "W"
        case unresolved_ucf = "U"
        case unresolved_unidocV3 = "C"

        case location = "L"
        case vector_self = "S"
        case vertex_self = "R"
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
        case .vertex(let id, text: let text):
            bson[.vertex_self] = id
            bson[.text] = text

        case .vector(let id, self: let heir, text: let text):
            bson[.vertex_self] = id
            bson[.vector_self] = heir
            bson[.text] = text

        case .unresolved(let self):
            bson[.location] = self.location

            switch self.type
            {
            case .doc:      bson[.unresolved_doc] = self.link
            case .web:      bson[.unresolved_web] = self.link
            case .ucf:      bson[.unresolved_ucf] = self.link
            case .unidocV3: bson[.unresolved_unidocV3] = self.link
            }
        }
    }
}
extension SymbolGraph.Outline:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        if  let id:Int32 = try bson[.vertex_self]?.decode()
        {
            let text:String = try bson[.text].decode()

            if  let heir:Int32 = try bson[.vector_self]?.decode()
            {
                self = .vector(id, self: heir, text: text)
            }
            else
            {
                self = .vertex(id, text: text)
            }

            return
        }

        let type:Unresolved.LinkType
        let link:String

        //  These are unscientifically ordered by likelihood.
        if  let text:String = try bson[.unresolved_ucf]?.decode()
        {
            type = .ucf
            link = text
        }
        else if
            let text:String = try bson[.unresolved_doc]?.decode()
        {
            type = .doc
            link = text
        }
        else if
            let text:String = try bson[.unresolved_web]?.decode()
        {
            type = .web
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
