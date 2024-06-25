extension HTTP
{
    @frozen public
    struct CookieValue:Equatable, Sendable
    {
        public
        let string:String

        @inlinable public
        init(_ string:String)
        {
            self.string = string
        }
    }
}
