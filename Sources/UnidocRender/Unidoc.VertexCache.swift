import UnidocRecords

extension Unidoc
{
    public
    protocol VertexCache<ID>:Identifiable
    {
        static
        func form(from vertices:consuming Vertices) -> Self

        subscript(_ vertex:Unidoc.Scalar) -> (vertex:AnyVertex, principal:Bool)? { get }
    }
}
