import UnidocRender

extension Swiftinit
{
    @frozen public
    enum Ptcl
    {
    }
}
extension Swiftinit.Ptcl:Unidoc.VertexLayer
{
    @inlinable public static
    var docs:Unidoc.ServerRoot { .ptcl }

    @inlinable public static
    var docc:Unidoc.ServerRoot { .ptcl }

    @inlinable public static
    var hist:Unidoc.ServerRoot { .ptcl }
}
