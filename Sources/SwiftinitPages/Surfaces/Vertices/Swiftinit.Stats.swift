extension Swiftinit
{
    enum Stats
    {
    }
}
extension Swiftinit.Stats:Swiftinit.VertexLayer
{
    static
    var docs:Swiftinit.Root { .stats }

    static
    var hist:Swiftinit.Root { .stats }
}
