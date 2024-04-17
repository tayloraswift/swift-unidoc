import S3

extension Unidoc.ServerOptions
{
    /// Options for the server that are configurable in development mode.
    @frozen public
    struct Development
    {
        /// Whether to enable CloudFront integration.
        public
        var cloudfront:Bool
        /// Whether to run the telescope plugin. Only effective when not running in mirror mode.
        public
        var runTelescope:Bool
        /// Whether to run the monitor plugin. Only effective when not running in mirror mode.
        public
        var runMonitor:Bool
        /// Whether to run the policy plugin.
        public
        var runPolicy:Bool

        /// The name of the replica set to use for development.
        public
        var replicaSet:String

        /// A test bucket for development. For this to work, you should probably make the bucket
        /// publically writable. It goes without saying that you should delete such a bucket
        /// as soon as you are done testing it.
        public
        var bucket:AWS.S3.Bucket?

        public
        var port:Int

        @inlinable public
        init()
        {
            self.cloudfront = false

            self.runTelescope = false
            self.runMonitor = false
            self.runPolicy = false

            self.replicaSet = "unidoc-rs"
            self.bucket = nil
            self.port = 8443
        }
    }
}
