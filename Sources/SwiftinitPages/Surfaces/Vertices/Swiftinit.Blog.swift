extension Swiftinit
{
    enum Blog
    {
    }
}
extension Swiftinit.Blog:Swiftinit.VertexLayer
{
    static
    var docs:Swiftinit.Root { .blog }

    static
    var hist:Swiftinit.Root { .blog }
}
