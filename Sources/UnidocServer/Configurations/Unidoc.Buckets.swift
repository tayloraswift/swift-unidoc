import S3

extension Unidoc
{
    @frozen public
    struct Buckets:Sendable
    {
        public
        var assets:AWS.S3.Bucket?
        public
        var graphs:AWS.S3.Bucket?

        @inlinable public
        init(assets:AWS.S3.Bucket? = nil, graphs:AWS.S3.Bucket? = nil)
        {
            self.assets = assets
            self.graphs = graphs
        }
    }
}
