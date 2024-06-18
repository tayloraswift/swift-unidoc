import PackageMetadata
import Symbols

extension SSGC.PackageBuild
{
    @frozen public
    enum ID:Hashable, Sendable
    {
        /// An unversioned SwiftPM build.
        case unversioned(Symbol.Package)
        /// A versioned SwiftPM build.
        case versioned(SPM.DependencyPin, reference:String?)
    }
}
extension SSGC.PackageBuild.ID
{
    var package:Symbol.Package
    {
        switch self
        {
        case    .unversioned(let id):   id
        case    .versioned(let pin, _): pin.identity
        }
    }
    var pin:SPM.DependencyPin?
    {
        switch self
        {
        case .unversioned:              nil
        case .versioned(let pin, _):    pin
        }
    }
}
