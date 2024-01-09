import UnidocRecords

extension Swiftinit
{
    @frozen public
    struct SecondaryOnly
    {
        @usableFromInline
        var secondary:[Unidoc.Scalar: Unidoc.AnyVertex]

        init(secondary:[Unidoc.Scalar: Unidoc.AnyVertex] = [:])
        {
            self.secondary = secondary
        }
    }
}
extension Swiftinit.SecondaryOnly:Identifiable
{
    @inlinable public
    var id:Never? { nil }
}
extension Swiftinit.SecondaryOnly:Swiftinit.VertexCache
{
    public static
    func form(from vertices:consuming Swiftinit.Vertices) -> Self
    {
        let principal:Unidoc.AnyVertex
        var secondary:[Unidoc.Scalar: Unidoc.AnyVertex]

        (principal, secondary) = { ($0.principal, $0.secondary) } (consume vertices)

        secondary[principal.id] = principal

        return .init(secondary: secondary)
    }

    public mutating
    func add(_ vertices:[Unidoc.AnyVertex])
    {
        for vertex:Unidoc.AnyVertex in vertices
        {
            self.secondary[vertex.id] = vertex
        }
    }

    @inlinable public
    subscript(_ vertex:Unidoc.Scalar) -> (vertex:Unidoc.AnyVertex, principal:Bool)?
    {
        self.secondary[vertex].map { ($0, false) }
    }
}
