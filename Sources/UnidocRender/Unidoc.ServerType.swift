extension Unidoc
{
    @frozen public
    enum ServerType
    {
        /// The official Swiftinit server.
        case swiftinit_org
        /// A local preview server.
        case localhost(port:Int)
    }
}
extension Unidoc.ServerType:CustomStringConvertible
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
