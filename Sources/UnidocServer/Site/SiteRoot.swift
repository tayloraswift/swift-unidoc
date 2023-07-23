import URI

protocol SiteRoot
{
    static
    var root:String { get }
}
extension SiteRoot
{
    static
    var uri:URI { [.push(self.root)] }
}
