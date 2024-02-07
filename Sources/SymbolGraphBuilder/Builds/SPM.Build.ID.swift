import PackageMetadata
import Symbols

extension SPM.Build
{
    @frozen public
    enum ID:Hashable, Sendable
    {
        /// An unversioned root package build.
        case unversioned(Symbol.Package)
        /// A versioned root package build.
        case versioned(SPM.DependencyPin, refname:String)
        /// A versioned dependency build.
        case upstream(SPM.DependencyPin)
    }
}
extension SPM.Build.ID
{
    var package:Symbol.Package
    {
        switch self
        {
        case    .unversioned(let id):   id
        case    .versioned(let pin, _),
                .upstream(let pin):     pin.identity
        }
    }
    var pin:SPM.DependencyPin?
    {
        switch self
        {
        case .unversioned:              nil
        case .versioned(let pin, _):    pin
        case .upstream(let pin):        pin
        }
    }
}
