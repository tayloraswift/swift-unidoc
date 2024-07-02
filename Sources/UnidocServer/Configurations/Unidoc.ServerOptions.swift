import GitHubAPI
import HTTPServer

extension Unidoc
{
    @dynamicMemberLookup
    @frozen public
    struct ServerOptions:Sendable
    {
        public
        let authority:any HTTP.ServerAuthority
        public
        var github:(any GitHub.Integration)?
        public
        var mirror:Bool
        public
        var bucket:Buckets
        public
        var mode:Mode

        @inlinable public
        init(authority:any HTTP.ServerAuthority,
            github:(any GitHub.Integration)? = nil,
            mirror:Bool = false,
            bucket:Buckets,
            mode:Mode = .production)
        {
            self.authority = authority
            self.github = github
            self.mirror = mirror
            self.bucket = bucket
            self.mode = mode
        }
    }
}
extension Unidoc.ServerOptions
{
    @inlinable
    var development:Development?
    {
        switch self.mode
        {
        case .development(_, let options):  options
        case .production:                   nil
        }
    }
}
extension Unidoc.ServerOptions
{
    @inlinable public
    subscript(dynamicMember keyPath:KeyPath<Development, Bool>) -> Bool
    {
        self.development?[keyPath: keyPath] ?? true
    }

    @inlinable public
    var replicaSet:String
    {
        self.development?.replicaSet ?? "swiftinit-rs"
    }

    @inlinable
    var port:Int
    {
        self.development?.port ?? 443
    }
}
