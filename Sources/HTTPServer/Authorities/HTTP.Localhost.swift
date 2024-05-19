extension HTTP
{
    @frozen public
    struct Localhost:ServerAuthority
    {
        public
        let context:Void

        @inlinable public
        init(context:Void = ())
        {
            self.context = context
        }

        @inlinable public static
        var scheme:Scheme { .http(port: 8080) }
        @inlinable public static
        var domain:String { "localhost" }
    }
}
