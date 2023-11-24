import PackageGraphs
import SemanticVersions
import SHA1
import Symbols

extension PackageManifest
{
    @frozen public
    struct DependencyPin:Identifiable, Equatable, Hashable, Sendable
    {
        public
        let id:Symbol.Package
        public
        let location:DependencyLocation
        public
        let revision:SHA1
        public
        let version:AnyVersion

        @inlinable public
        init(id:Symbol.Package,
            location:DependencyLocation,
            revision:SHA1,
            version:AnyVersion)
        {
            self.id = id
            self.location = location
            self.revision = revision
            self.version = version
        }
    }
}
extension PackageManifest.DependencyPin
{
    @inlinable public
    init(id:Symbol.Package,
        location:PackageManifest.DependencyLocation,
        state:PackageManifest.DependencyState)
    {
        self.init(id: id,
            location: location,
            revision: state.revision,
            version: state.version)
    }
    @inlinable public
    var state:PackageManifest.DependencyState
    {
        .init(revision: self.revision, version: self.version)
    }
}
