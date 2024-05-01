import UnidocRecords

extension Unidoc
{
    public
    protocol VertexContextTable<ID>:Identifiable
    {
        init(principal:AnyVertex, secondary:borrowing [AnyVertex])

        subscript(_ vertex:Unidoc.Scalar) -> (vertex:AnyVertex, principal:Bool)? { get }
    }
}
