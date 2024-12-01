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

        @inlinable public
        var binding:Origin { .init(scheme: .http, domain: "localhost:8080") }
    }
}
