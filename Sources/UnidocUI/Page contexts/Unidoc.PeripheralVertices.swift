import UnidocRecords
import UnidocRender

extension Unidoc
{
    @frozen public
    struct PeripheralVertices
    {
        @usableFromInline
        var secondary:[Unidoc.Scalar: AnyVertex]

        private
        init(secondary:[Unidoc.Scalar: AnyVertex] = [:])
        {
            self.secondary = secondary
        }
    }
}
extension Unidoc.PeripheralVertices
{
    public
    init(secondary:borrowing [Unidoc.AnyVertex])
    {
        self.init(secondary: secondary.reduce(into: [:]) { $0[$1.id] = $1 })
    }
}
extension Unidoc.PeripheralVertices:Identifiable
{
    @inlinable public
    var id:Never? { nil }
}
extension Unidoc.PeripheralVertices:Unidoc.VertexContextTable
{
    @inlinable public
    init(principal:Unidoc.AnyVertex, secondary:borrowing [Unidoc.AnyVertex])
    {
        self.init(secondary: secondary)
        self.secondary[principal.id] = principal
    }

    @inlinable public
    subscript(_ vertex:Unidoc.Scalar) -> (vertex:Unidoc.AnyVertex, principal:Bool)?
    {
        self.secondary[vertex].map { ($0, false) }
    }
}
