import UnidocRecords

extension Swiftinit
{
    @frozen public
    struct Vertices
    {
        @usableFromInline
        let principal:Unidoc.AnyVertex
        @usableFromInline
        var secondary:[Unidoc.Scalar: Unidoc.AnyVertex]

        init(
            principal:Unidoc.AnyVertex,
            secondary:[Unidoc.Scalar: Unidoc.AnyVertex] = [:])
        {
            self.principal = principal
            self.secondary = secondary
        }
    }
}
extension Swiftinit.Vertices:Identifiable
{
    @inlinable public
    var id:Unidoc.Scalar { self.principal.id }
}
extension Swiftinit.Vertices:Swiftinit.VertexCache
{
    @inlinable public static
    func form(from self:consuming Swiftinit.Vertices) -> Self { `self` }

    public mutating
    func add(_ vertices:[Unidoc.AnyVertex])
    {
        for vertex:Unidoc.AnyVertex in vertices where self.principal.id != vertex.id
        {
            self.secondary[vertex.id] = vertex
        }
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
