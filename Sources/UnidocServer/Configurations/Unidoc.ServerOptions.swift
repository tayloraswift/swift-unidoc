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
        var builders:Int
        public
        var bucket:Buckets
        public
        var github:(any GitHub.Integration)?

        /// Whether to enforce account-level permissions.
        public
        var access:AccessControl
        public
        var origin:HTTP.ServerOrigin
        public
        var preview:Bool

        @inlinable public
        init(
            assetCache:Unidoc.Cache<Unidoc.Asset>?,
            builders:Int,
            bucket:Buckets,
            github:(any GitHub.Integration)?,
            access:AccessControl,
            origin:HTTP.ServerOrigin,
            preview:Bool)
        {
            self.assetCache = assetCache
            self.builders = builders
            self.bucket = bucket
            self.github = github

            self.access = access
            self.origin = origin
            self.preview = preview
        }
    }
}
