extension Unidoc.Permissions
{
    enum Global
    {
        /// Authenticated.
        case authenticated(Unidoc.User.Level)
        /// Not authenticated, running in local development mode.
        case developer
        /// Not authenticated, running in production mode.
        case guest
    }
}
