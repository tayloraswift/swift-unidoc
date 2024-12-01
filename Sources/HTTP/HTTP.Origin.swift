extension HTTP
{
    @frozen public
    struct Origin:Sendable
    {
        /// The value of the domain, including the port if not the default.
        /// Does not include the scheme.
        public
        let domain:String
        public
        let scheme:Scheme

        @inlinable public
        init(scheme:Scheme, domain:String)
        {
            self.domain = domain
            self.scheme = scheme
        }
    }
}
extension HTTP.Origin:CustomStringConvertible
{
    /// Formats the origin as a string, including the scheme, and the port if present, but not
    /// including any trailing slash.
    @inlinable public
    var description:String { "\(self.scheme.name)://\(self.domain)" }
}
