extension Swiftinit.RenderFormat
{
    @frozen public
    enum Server
    {
        case swiftinit_org
        case localhost(port:Int)
    }
}
extension Swiftinit.RenderFormat.Server
{
    @inlinable public
    var loopback:String?
    {
        switch self
        {
        case .swiftinit_org:        nil
        case .localhost(let port):  "http://127.0.0.1:\(port)"
        }
    }
}
