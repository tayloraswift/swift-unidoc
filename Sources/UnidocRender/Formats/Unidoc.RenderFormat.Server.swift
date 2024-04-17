extension Unidoc.RenderFormat
{
    @frozen public
    enum Server
    {
        case swiftinit_org
        case localhost(port:Int)
    }
}
extension Unidoc.RenderFormat.Server:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        switch self
        {
        case .swiftinit_org:        "https://swiftinit.org"
        case .localhost(let port):  "https://localhost:\(port)"
        }
    }
}
