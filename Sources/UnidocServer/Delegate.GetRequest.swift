import HTTPServer
import NIOCore
import NIOHTTP1
import URI

extension Delegate
{
    struct GetRequest:Sendable
    {
        let promise:EventLoopPromise<ServerResponse>
        let branch:Get

        init(promise:EventLoopPromise<ServerResponse>, branch:Get)
        {
            self.promise = promise
            self.branch = branch
        }
    }
}
extension Delegate.GetRequest:ServerDelegateGetRequest
{
    init?(_ uri:String,
        address _:SocketAddress?,
        headers _:HTTPHeaders,
        with promise:() -> EventLoopPromise<ServerResponse>)
    {
        guard let uri:URI = .init(uri)
        else
        {
            return nil
        }

        let path:[String] = uri.path.normalized(lowercase: true)

        guard let first:String = path.first
        else
        {
            return nil
        }

        let rest:ArraySlice<String> = path.dropFirst()
        let get:Delegate.Get?

        switch first
        {
        case Site.Admin.root:   get = .admin(rest)
        case Site.Assets.root:  get = .asset(rest)
        case Site.Docs.root:    get = .db   (rest, planes:  .docs, uri: uri)
        case Site.Learn.root:   get = .db   (rest, planes: .learn, uri: uri)
        case _:         return nil
        }

        if  let get:Delegate.Get
        {
            self.init(promise: promise(), branch: get)
        }
        else
        {
            return nil
        }
    }
}
