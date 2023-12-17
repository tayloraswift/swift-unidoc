import PackageGraphs
import SemanticVersions
import SHA1
import Symbols

extension SPM
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
extension SPM.DependencyPin
{
    @inlinable public
    init(id:Symbol.Package,
        location:SPM.DependencyLocation,
        state:SPM.DependencyState)
    {
        self.init(id: id,
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
