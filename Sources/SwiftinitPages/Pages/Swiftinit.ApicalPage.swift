import UnidocRecords

extension Swiftinit
{
    public
    typealias ApicalPage = _SwiftinitApicalPage
}

public
protocol _SwiftinitApicalPage<Apex>:Swiftinit.VertexPage
{
    associatedtype Apex:Unidoc.PrincipalVertex

    var mesh:Swiftinit.Mesh { get }
    var apex:Apex { get }

    var descriptionFallback:String { get }
}
extension Swiftinit.ApicalPage
{
    var descriptionFallback:String { "No overview available" }

    /// This needs to be optional, to prevent the default implementation from being used.
    var description:String? { self.mesh.overview?.description ?? self.descriptionFallback }
}
extension Swiftinit.ApicalPage
    where Context == IdentifiablePageContext<Swiftinit.Vertices>
{
    var context:IdentifiablePageContext<Swiftinit.Vertices> { self.mesh.halo.context }
}
