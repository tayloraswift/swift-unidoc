import HTML
import HTTP
import HTTPServer
import IP

extension Unidoc
{
    @frozen public
    struct ServerError:Error, Sendable
    {
        @usableFromInline
        let details:String
        @usableFromInline
        let origin:HTTP.ServerRequest.Origin?
        @usableFromInline
        let type:String
        @usableFromInline
        let path:String?

        @inlinable public
        init(details:String,
            type:String,
            from origin:HTTP.ServerRequest.Origin?,
            path:String?)
        {
            self.details = details
            self.origin = origin
            self.type = type
            self.path = path
        }
    }
}
extension Unidoc.ServerError
{
    init(error:__shared any Error,
        type:String? = nil,
        from origin:HTTP.ServerRequest.Origin? = nil,
        path:String? = nil)
    {
        self.init(details: String.init(reflecting: error),
            type: type ?? String.init(reflecting: Swift.type(of: error)),
            from: origin,
            path: path)
    }
}
extension Unidoc.ServerError:Unidoc.ServerEvent
{
    @inlinable public
    func h3(_ h3:inout HTML.ContentEncoder)
    {
        h3 += "Server error"
    }

    @inlinable public
    func dl(_ dl:inout HTML.ContentEncoder)
    {
        dl[.dt] = "Type"
        dl[.dd] = self.type

        if  let origin:HTTP.ServerRequest.Origin = self.origin
        {
            dl[.dt] = "Origin"
            dl[.dd] = "\(origin.ip)"
        }

        if  let path:String = self.path
        {
            dl[.dt] = "Path"
            dl[.dd] {$0[.a] { $0.target = "_blank" ; $0.href = path } = path }
        }

        dl[.dt] = "Description"
        dl[.dd, .pre] = self.details
    }
}
