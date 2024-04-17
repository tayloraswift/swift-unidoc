import UnidocRender

extension Swiftinit
{
    @frozen public
    enum Blog
    {
    }
}
extension Swiftinit.Blog:Unidoc.VertexLayer
{
    @inlinable public static
    var docs:Unidoc.ServerRoot { .blog }

    @inlinable public static
    var docc:Unidoc.ServerRoot { .blog }

    @inlinable public static
    var hist:Unidoc.ServerRoot { .blog }
}
