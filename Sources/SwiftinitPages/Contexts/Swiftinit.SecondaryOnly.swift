import UnidocRecords

extension Swiftinit
{
    @frozen public
    struct SecondaryOnly
    {
        @usableFromInline
        var secondary:[Unidoc.Scalar: Unidoc.AnyVertex]

        private
        init(secondary:[Unidoc.Scalar: Unidoc.AnyVertex] = [:])
        {
            self.secondary = secondary
        }
    }
}
extension Swiftinit.SecondaryOnly
{
    init(secondary:[Unidoc.AnyVertex])
    {
        self.init(secondary: secondary.reduce(into: [:]) { $0[$1.id] = $1 })
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

    @inlinable public
    subscript(_ vertex:Unidoc.Scalar) -> (vertex:Unidoc.AnyVertex, principal:Bool)?
    {
        self.secondary[vertex].map { ($0, false) }
    }
}
