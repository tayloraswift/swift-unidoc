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
extension Unidoc.VertexTypeError
{
    static
    func reject(_ vertex:Unidoc.AnyVertex) -> Self
    {
        switch vertex
        {
        case .article:  .article
        case .culture:  .culture
        case .decl:     .decl
        case .file:     .file
        case .product:  .product
        case .foreign:  .foreign
        case .global:   .global
        }
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
