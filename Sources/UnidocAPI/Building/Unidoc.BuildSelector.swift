extension Unidoc
{
    @frozen public
    enum BuildSelector<Package>
    {
        /// Build a specific edition of a package.
        case id(Edition)
        /// Build the latest version of a package.
        case latest(VersionSeries, of:Package)
    }
}
extension Unidoc.BuildSelector<Void>
{
    @inlinable public
    static func latest(_ series:Unidoc.VersionSeries) -> Self
    {
        .latest(series, of: ())
    }
}
extension Unidoc.BuildSelector
{
    @inlinable public
    var exact:Unidoc.Edition?
    {
        switch self
        {
        case .id(let id):   id
        case .latest:       nil
        }
    }
}
extension Unidoc.BuildSelector:Equatable where Package:Equatable
{
}
extension Unidoc.BuildSelector:Sendable where Package:Sendable
{
}
