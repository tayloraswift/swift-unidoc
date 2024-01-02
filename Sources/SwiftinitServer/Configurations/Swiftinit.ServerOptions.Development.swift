extension Swiftinit.ServerOptions
{
    /// Options for the server that are configurable in development mode.
    struct Development
    {
        /// Whether to enable CloudFront integration.
        var cloudfront:Bool
        /// Whether to enable IP whitelisting.
        var whitelists:Bool

        var port:Int

        init()
        {
            self.cloudfront = false
            self.whitelists = false

            self.port = 8443
        }
    }
}
