import Media

extension HTTP
{
    @frozen public
    enum ServerResponse:Sendable
    {
        case resource(Resource, status:UInt)
        case redirect(Redirect, cookies:[(name:String, value:HTTP.CookieValue)] = [])
    }
}
extension HTTP.ServerResponse
{
    @inlinable public
    static func ok(_ resource:HTTP.Resource) -> Self
    {
        .resource(resource, status: 200)
    }

    @inlinable public
    static func created(_ resource:HTTP.Resource) -> Self
    {
        .resource(resource, status: 201)
    }

    @inlinable public
    static var noContent:Self
    {
        .resource("", status: 204)
    }

    @inlinable public
    static func multiple(_ resource:HTTP.Resource) -> Self
    {
        .resource(resource, status: 300)
    }

    @inlinable public
    static func unauthorized(_ resource:HTTP.Resource) -> Self
    {
        .resource(resource, status: 401)
    }

    @inlinable public
    static func forbidden(_ resource:HTTP.Resource) -> Self
    {
        .resource(resource, status: 403)
    }

    @inlinable public
    static func notFound(_ resource:HTTP.Resource) -> Self
    {
        .resource(resource, status: 404)
    }

    @inlinable public
    static func gone(_ resource:HTTP.Resource) -> Self
    {
        .resource(resource, status: 410)
    }

    @inlinable public
    static func unsupportedMediaType(_ resource:HTTP.Resource) -> Self
    {
        .resource(resource, status: 415)
    }

    @inlinable public
    static func error(_ resource:HTTP.Resource) -> Self
    {
        .resource(resource, status: 500)
    }
}
extension HTTP.ServerResponse
{
    @inlinable public
    var size:Int
    {
        switch self
        {
        case .redirect:                 0
        case .resource(let self, _):    self.content?.body.size ?? 0
        }
    }
}
