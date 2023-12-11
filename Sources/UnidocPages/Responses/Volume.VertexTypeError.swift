import UnidocRecords

extension Volume
{
    enum VertexTypeError:Error, Equatable, Sendable
    {
        case article
        case culture
        case decl
        case file
        case foreign
        case global
    }
}
extension Volume.VertexTypeError:CustomStringConvertible
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
        case .foreign:  name = "foreign"
        case .global:   name = "global"
        }

        return "unexpected vertex type (\(name))"
    }
}
