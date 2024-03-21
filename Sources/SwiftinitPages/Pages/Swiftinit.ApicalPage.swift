import UnidocRecords

extension Swiftinit
{
    public
    protocol ApicalPage<Apex>:VertexPage
    {
        associatedtype Apex:Unidoc.PrincipalVertex

        var mesh:Mesh { get }
        var apex:Apex { get }

        var descriptionFallback:String { get }
    }
}
extension Swiftinit.ApicalPage
{
    var descriptionFallback:String { "No overview available" }

    /// This needs to be optional, to prevent the default implementation from being used.
    var description:String? { self.mesh.overview?.description ?? self.descriptionFallback }
}
extension Swiftinit.ApicalPage
    where Context == Unidoc.RelativePageContext
{
    var context:Unidoc.RelativePageContext { self.mesh.halo.context }
}
