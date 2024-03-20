import UnidocRecords

extension Swiftinit
{
    public
    protocol VertexCache<ID>:Identifiable
    {
        static
        func form(from vertices:consuming Swiftinit.Vertices) -> Self

        subscript(_ vertex:Unidoc.Scalar) -> (vertex:Unidoc.AnyVertex, principal:Bool)? { get }
    }
}
