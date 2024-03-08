extension Unidoc
{
    @frozen public
    enum VersionsPredicate:Equatable, Hashable, Sendable
    {
        case prereleases(limit:Int, page:Int = 0)
        case releases(limit:Int, page:Int = 0)
        case tags(limit:Int, user:Unidoc.User.ID? = nil)
    }
}
