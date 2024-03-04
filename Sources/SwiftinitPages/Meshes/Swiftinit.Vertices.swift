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

        private
        init(
            principal:Unidoc.AnyVertex,
            secondary:[Unidoc.Scalar: Unidoc.AnyVertex] = [:])
        {
            self.principal = principal
            self.secondary = secondary
        }
    }
}
extension Swiftinit.Vertices
{
    init(
        principal:Unidoc.AnyVertex,
        secondary:[Unidoc.AnyVertex])
    {
        let secondary:[Unidoc.Scalar: Unidoc.AnyVertex] = secondary.reduce(into: [:])
        {
            $0[$1.id] = principal.id != $1.id ? $1 : nil
        }
        self.init(principal: principal, secondary: secondary)
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

    @inlinable public
    subscript(_ vertex:Unidoc.Scalar) -> (vertex:Unidoc.AnyVertex, principal:Bool)?
    {
        self.principal.id == vertex ? (self.principal, true) : self.secondary[vertex].map
        {
            ($0, false)
        }
    }
}
