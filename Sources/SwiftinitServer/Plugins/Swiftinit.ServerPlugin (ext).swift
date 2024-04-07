extension Swiftinit.ServerPlugin
{
    var page:(any Unidoc.RenderablePage)? { self.status.load() }
}
