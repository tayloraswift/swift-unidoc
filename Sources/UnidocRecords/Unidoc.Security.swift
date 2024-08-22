extension Unidoc
{
    @frozen public
    enum Security:Equatable, Sendable
    {
        /// The server will enforce account-level permissions.
        case enforced
        /// The server will treat everyone as if they were an administratrix.
        case ignored
    }
}
