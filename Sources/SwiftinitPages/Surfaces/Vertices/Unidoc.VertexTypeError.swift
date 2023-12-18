import UnidocRecords

extension Unidoc
{
    enum VertexTypeError:Error, Equatable, Sendable
    {
        case article
        case culture
        case decl
        case file
        case product
        case foreign
        case global
    }
}
extension Unidoc.VertexTypeError:CustomStringConvertible
{
    var description:String
    {
        let name:String

        switch self
        {
        case .article:  name = "article"
        case .culture:  name = "culture"
        case .decl:     name = "decl"
        case .file:     name = "file"
        case .product:  name = "product"
        case .foreign:  name = "foreign"
        case .global:   name = "global"
        }

        return "unexpected vertex type (\(name))"
    }
}
