extension SwiftinitClient
{
    @frozen public
    struct StatusError:Equatable, Sendable, Error
    {
        /// The response status code, if it could be parsed, nil otherwise.
        public
        let code:UInt?

        @inlinable public
        init(code:UInt?)
        {
            self.code = code
        }
    }
}
extension SwiftinitClient.StatusError:CustomStringConvertible
{
    public
    var description:String
    {
        self.code?.description ?? "unknown"
    }
}
