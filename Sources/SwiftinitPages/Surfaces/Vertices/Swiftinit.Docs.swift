extension Swiftinit
{
    @frozen public
    enum Docs
    {
    }
}
extension Swiftinit.Docs:Swiftinit.VertexLayer
{
    @inlinable public static
    var docs:Swiftinit.Root { .docs }

    @inlinable public static
    var docc:Swiftinit.Root { .docc }

    @inlinable public static
    var hist:Swiftinit.Root { .hist }
}
