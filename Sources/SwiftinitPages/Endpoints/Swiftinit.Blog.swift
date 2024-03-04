extension Swiftinit
{
    @frozen public
    enum Blog
    {
    }
}
extension Swiftinit.Blog:Swiftinit.VertexLayer
{
    @inlinable public static
    var docs:Swiftinit.Root { .blog }

    @inlinable public static
    var docc:Swiftinit.Root { .blog }

    @inlinable public static
    var hist:Swiftinit.Root { .blog }
}
