import S3

extension Swiftinit
{
    struct Buckets:Sendable
    {
        var assets:AWS.S3.Bucket?
        var graphs:AWS.S3.Bucket?

        init(assets:AWS.S3.Bucket? = nil, graphs:AWS.S3.Bucket? = nil)
        {
            self.assets = assets
            self.graphs = graphs
        }
    }
}
