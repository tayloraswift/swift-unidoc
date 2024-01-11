extension Swiftinit.ServerPlugin
{
    var page:(any Swiftinit.RenderablePage)? { self.status.load() }
}
