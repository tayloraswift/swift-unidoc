extension AnyVersion
{
    @frozen public
    enum Canonical:Hashable, Equatable, Sendable
    {
        case stable(SemanticVersion)
        case unstable(String)
    }
}
extension AnyVersion.Canonical:CustomStringConvertible
{
    /// A *human-readable* description of this semantic ref name. This isn’t the
    /// same as its actual name (which is lost on parsing), and cannot be used to
    /// checkout a snapshot of the associated repository.
    public
    var description:String
    {
        switch self
        {
        case .stable(let version):              return "\(version) (stable)"
        case .unstable(let name):               return "\(name) (unstable)"
        }
    }
}
