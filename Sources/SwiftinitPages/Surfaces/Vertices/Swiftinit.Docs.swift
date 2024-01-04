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
    var docc:Swiftinit.Root { .docc }

    static
    var hist:Swiftinit.Root { .hist }
}
