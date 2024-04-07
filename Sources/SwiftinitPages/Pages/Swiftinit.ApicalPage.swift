import UnidocRecords

extension Swiftinit
{
    public
    protocol ApicalPage<Apex>:VertexPage
    {
        associatedtype Apex:Unidoc.PrincipalVertex

        var cone:Unidoc.Cone { get }
        var apex:Apex { get }

        var descriptionFallback:String { get }
    }
}
extension Swiftinit.ApicalPage
{
    var descriptionFallback:String { "No overview available" }

    /// This needs to be optional, to prevent the default implementation from being used.
    var description:String? { self.cone.overview?.description ?? self.descriptionFallback }
}
extension Swiftinit.ApicalPage
    where Context == Unidoc.RelativePageContext
{
    var context:Unidoc.RelativePageContext { self.cone.halo.context }
}
