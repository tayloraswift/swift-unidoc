extension Unidoc
{
    @frozen public
    enum VersionsPredicate:Equatable, Hashable, Sendable
    {
        case tags(limit:Int, page:Int = 0, beta:Bool)
        case none(limit:Int)
    }
}
