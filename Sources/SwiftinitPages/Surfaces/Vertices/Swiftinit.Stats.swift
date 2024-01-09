extension Swiftinit
{
    @frozen public
    enum Stats
    {
    }
}
extension Swiftinit.Stats:Swiftinit.VertexLayer
{
    @inlinable public static
    var docs:Swiftinit.Root { .stats }

    @inlinable public static
    var docc:Swiftinit.Root { .stats }

    @inlinable public static
    var hist:Swiftinit.Root { .stats }
}
