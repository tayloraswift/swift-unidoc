import URI

extension Site
{
    enum Assets
    {
    }
}
extension Site.Assets:SiteRoot
{
    static
    var root:String { "assets" }
}
extension Site.Assets
{
    static
    subscript(asset:Delegate.Get.Asset) -> URI
    {
        var uri:URI = Self.uri
            uri.path.append("\(asset)")
        return uri
    }
}
