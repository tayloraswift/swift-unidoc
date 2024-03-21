import UnidocRecords

extension Unidoc
{
    @frozen public
    struct Vertices
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
extension Unidoc.Vertices
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
}
extension Unidoc.Vertices:Identifiable
{
    @inlinable public
    var id:Unidoc.Scalar { self.principal.id }
}
extension Unidoc.Vertices:Unidoc.VertexCache
{
    @inlinable public static
    func form(from self:consuming Unidoc.Vertices) -> Self { `self` }

    @inlinable public
    subscript(_ vertex:Unidoc.Scalar) -> (vertex:Unidoc.AnyVertex, principal:Bool)?
    {
        self.principal.id == vertex ? (self.principal, true) : self.secondary[vertex].map
        {
            ($0, false)
        }
    }
}
