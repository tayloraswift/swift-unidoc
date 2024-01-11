import UnidocRecords

extension Swiftinit
{
    public
    typealias VertexCache = _SwiftinitVertexCache
}

/// The name of this protocol is ``Swiftinit.VertexCache``.
public
protocol _SwiftinitVertexCache<ID>:Identifiable
{
    static
    func form(from vertices:consuming Swiftinit.Vertices) -> Self

    subscript(_ vertex:Unidoc.Scalar) -> (vertex:Unidoc.AnyVertex, principal:Bool)? { get }
}
