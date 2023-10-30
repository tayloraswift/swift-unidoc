extension CodelinkV3.Path
{
    enum Format:Equatable, Hashable, Sendable
    {
        /// Legacy DocC format, uses slashes (`/`) as the path separator.
        case legacy
        /// Unidoc format, uses dots (`.`) as the path separator.
        case unidoc
    }
}
