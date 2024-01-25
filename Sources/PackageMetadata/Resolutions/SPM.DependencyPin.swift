import PackageGraphs
import SemanticVersions
import SHA1
import Symbols

extension SPM
{
    @frozen public
    struct DependencyPin:Equatable, Hashable, Sendable
    {
        /// The **local** identity of the package.
        public
        let identity:Symbol.Package
        public
        let location:DependencyLocation
        public
        let revision:SHA1
        public
        let version:AnyVersion

        @inlinable public
        init(identity:Symbol.Package,
            location:DependencyLocation,
            revision:SHA1,
            version:AnyVersion)
        {
            self.identity = identity
            self.location = location
            self.revision = revision
            self.version = version
        }
    }
}
extension SPM.DependencyPin
{
    @inlinable public
    init(identity:Symbol.Package,
        location:SPM.DependencyLocation,
        state:SPM.DependencyState)
    {
        self.init(identity: identity,
            location: location,
            revision: state.revision,
            version: state.version)
    }
    @inlinable public
    var state:SPM.DependencyState
    {
        .init(revision: self.revision, version: self.version)
    }
}
