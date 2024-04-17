import UnidocRender

extension Swiftinit
{
    @frozen public
    enum Stats
    {
    }
}
extension Swiftinit.Stats:Unidoc.VertexLayer
{
    @inlinable public static
    var docs:Unidoc.ServerRoot { .stats }

    @inlinable public static
    var docc:Unidoc.ServerRoot { .stats }

    @inlinable public static
    var hist:Unidoc.ServerRoot { .stats }
}
