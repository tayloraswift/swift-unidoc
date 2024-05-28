import UnidocRecords

extension Unidoc
{
    public
    protocol ApicalPage<Apex>:VertexPage
    {
        associatedtype Apex:PrincipalVertex

        var cone:Cone { get }
        var apex:Apex { get }

        var descriptionFallback:String { get }
    }
}
extension Unidoc.ApicalPage
{
    var descriptionFallback:String { "No overview available" }

    /// This needs to be optional, to prevent the default implementation from being used.
    var description:String?
    {
        self.cone.overviewText?.description ?? self.descriptionFallback
    }
}
extension Unidoc.ApicalPage where Context == Unidoc.InternalPageContext
{
    var context:Unidoc.InternalPageContext { self.cone.halo.context }
}
