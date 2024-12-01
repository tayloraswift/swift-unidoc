import GitHubAPI
import HTTPServer
import UnidocAssets
import UnidocRecords

extension Unidoc
{
    @frozen public
    struct ServerOptions:Sendable
    {
        public
        var assetCache:Unidoc.Cache<Unidoc.Asset>?
        public
        let authority:any HTTP.ServerAuthority
        public
        var builders:Int
        public
        var bucket:Buckets
        public
        var github:(any GitHub.Integration)?

        /// Whether to enforce account-level permissions.
        public
        var access:AccessControl
        public
        var preview:Bool

        @inlinable public
        init(
            assetCache:Unidoc.Cache<Unidoc.Asset>?,
            authority:any HTTP.ServerAuthority,
            builders:Int,
            bucket:Buckets,
            github:(any GitHub.Integration)?,
            access:AccessControl,
            preview:Bool)
        {
            self.assetCache = assetCache
            self.authority = authority
            self.builders = builders
            self.bucket = bucket
            self.github = github

            self.access = access
            self.preview = preview
        }
    }
}
