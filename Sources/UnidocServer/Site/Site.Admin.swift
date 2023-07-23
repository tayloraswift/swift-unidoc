extension Site
{
    enum Admin
    {
    }
}
extension Site.Admin:SiteRoot
{
    static
    var root:String { "admin" }
}
