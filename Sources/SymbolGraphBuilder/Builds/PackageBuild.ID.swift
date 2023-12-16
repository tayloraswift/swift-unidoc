import PackageMetadata
import Symbols

extension PackageBuild
{
    @frozen public
    enum ID:Hashable, Sendable
    {
        /// An unversioned root package build.
        case unversioned(Symbol.Package)
        /// A versioned root package build.
        case versioned(PackageManifest.DependencyPin, refname:String)
        /// A versioned dependency build.
        case upstream(PackageManifest.DependencyPin)
    }
}
extension PackageBuild.ID
{
    var package:Symbol.Package
    {
        switch self
        {
        case    .unversioned(let id):   id
        case    .versioned(let pin, _),
                .upstream(let pin):     pin.id
        }
    }
    var pin:PackageManifest.DependencyPin?
    {
        switch self
        {
        case    .unversioned:           nil
        case    .versioned(let pin, _),
                .upstream(let pin):     pin
        }
    }
}
