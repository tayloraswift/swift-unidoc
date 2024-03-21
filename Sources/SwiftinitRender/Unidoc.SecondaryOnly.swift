import UnidocRecords

extension Unidoc
{
    @frozen public
    struct SecondaryOnly
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
extension Unidoc.SecondaryOnly
{
    public
    init(secondary:borrowing [Unidoc.AnyVertex])
    {
        self.init(secondary: secondary.reduce(into: [:]) { $0[$1.id] = $1 })
    }
}
extension Unidoc.SecondaryOnly:Identifiable
{
    @inlinable public
    var id:Never? { nil }
}
extension Unidoc.SecondaryOnly:Unidoc.VertexCache
{
    public static
    func form(from vertices:consuming Unidoc.Vertices) -> Self
    {
        let principal:Unidoc.AnyVertex
        var secondary:[Unidoc.Scalar: Unidoc.AnyVertex]

        (principal, secondary) = { ($0.principal, $0.secondary) } (consume vertices)

        secondary[principal.id] = principal

        return .init(secondary: secondary)
    }

    @inlinable public
    subscript(_ vertex:Unidoc.Scalar) -> (vertex:Unidoc.AnyVertex, principal:Bool)?
    {
        self.secondary[vertex].map { ($0, false) }
    }
}
