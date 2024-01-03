extension Swiftinit
{
    enum Docs
    {
    }
}
extension Swiftinit.Docs:Swiftinit.VertexLayer
{
    static
    var docs:Swiftinit.Root { .docs }

    static
    var hist:Swiftinit.Root { .hist }
}
