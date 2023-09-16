import SemanticVersions

extension Repository.Pin
{
    @frozen public
    struct State:Equatable, Hashable, Sendable
    {
        public
        let revision:Repository.Revision
        public
        let version:AnyVersion

        @inlinable public
        init(revision:Repository.Revision, version:AnyVersion)
        {
            self.revision = revision
            self.version = version
        }
    }
}
extension Repository.Pin.State:CustomStringConvertible
{
    /// A *human-readable* description of this semantic ref name. This isn’t the
    /// same as its actual name (which is lost on parsing), and cannot be used to
    /// checkout a snapshot of the associated repository.
    public
    var description:String
    {
        switch self.version.canonical
        {
        case .stable(let version):
            return "\(version) (stable, \(self.revision))"

        case .unstable(let name):
            return "\(name) (unstable, \(self.revision))"
        }
    }
}
