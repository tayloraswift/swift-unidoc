import S3

extension Swiftinit.ServerOptions
{
    /// Options for the server that are configurable in development mode.
    struct Development
    {
        /// Whether to enable CloudFront integration.
        var cloudfront:Bool
        /// Whether to enable IP whitelisting.
        var whitelists:Bool

        /// A test bucket for development. For this to work, you should probably make the bucket
        /// publically writable. It goes without saying that you should delete such a bucket
        /// as soon as you are done testing it.
        var bucket:AWS.S3.Bucket?

        var port:Int

        init()
        {
            self.cloudfront = false
            self.whitelists = false

            self.bucket = nil

            self.port = 8443
        }
    }
}
