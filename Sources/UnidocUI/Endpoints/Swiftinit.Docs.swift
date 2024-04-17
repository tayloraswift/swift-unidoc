import UnidocRender

extension Swiftinit
{
    @frozen public
    enum Docs
    {
    }
}
extension Swiftinit.Docs:Unidoc.VertexLayer
{
    @inlinable public static
    var docs:Unidoc.ServerRoot { .docs }

    @inlinable public static
    var docc:Unidoc.ServerRoot { .docc }

    @inlinable public static
    var hist:Unidoc.ServerRoot { .hist }
}
