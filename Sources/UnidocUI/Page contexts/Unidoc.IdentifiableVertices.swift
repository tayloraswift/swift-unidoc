import UnidocRecords
import UnidocRender

extension Unidoc
{
    @frozen public
    struct IdentifiableVertices
    {
        @usableFromInline
        let principal:AnyVertex
        @usableFromInline
        var secondary:[Unidoc.Scalar: AnyVertex]

        private
        init(
            principal:AnyVertex,
            secondary:[Unidoc.Scalar: AnyVertex] = [:])
        {
            self.principal = principal
            self.secondary = secondary
        }
    }
}
extension Unidoc.IdentifiableVertices:Identifiable
{
    @inlinable public
    var id:Unidoc.Scalar { self.principal.id }
}
extension Unidoc.IdentifiableVertices:Unidoc.VertexContextTable
{
    public
    init(principal:Unidoc.AnyVertex, secondary:borrowing [Unidoc.AnyVertex])
    {
        let secondary:[Unidoc.Scalar: Unidoc.AnyVertex] = secondary.reduce(into: [:])
        {
            $0[$1.id] = principal.id != $1.id ? $1 : nil
        }
        self.init(principal: principal, secondary: secondary)
    }

    @inlinable public
    subscript(_ vertex:Unidoc.Scalar) -> (vertex:Unidoc.AnyVertex, principal:Bool)?
    {
        self.principal.id == vertex ? (self.principal, true) : self.secondary[vertex].map
        {
            ($0, false)
        }
    }
}
