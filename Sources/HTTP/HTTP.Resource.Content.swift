import Media

extension HTTP.Resource
{
    @frozen public
    struct Content:Equatable, Sendable
    {
        public
        var body:Body
        public
        var type:MediaType
        public
        var encoding:MediaEncoding?

        @inlinable public
        init(body:Body, type:MediaType, encoding:MediaEncoding? = nil)
        {
            self.body = body
            self.type = type
            self.encoding = encoding
        }
    }
}
