import ModuleGraphs

extension PackageBuild
{
    @frozen public
    enum Identity:Hashable, Sendable
    {
        /// An unversioned root package build.
        case unversioned(PackageIdentifier)
        /// A versioned root package build.
        case versioned(Repository.Pin, refname:String)
        /// A versioned dependency build.
        case upstream(Repository.Pin)
    }
}
extension PackageBuild.Identity
{
    var package:PackageIdentifier
    {
        switch self
        {
        case    .unversioned(let id):   return id
        case    .versioned(let pin, _),
                .upstream(let pin):     return pin.id
        }
    }
    var pin:Repository.Pin?
    {
        switch self
        {
        case    .unversioned:           return nil
        case    .versioned(let pin, _),
                .upstream(let pin):     return pin
        }
    }
    var refname:String?
    {
        switch self
        {
        case    .unversioned,
                .upstream:                  return nil
        case    .versioned(_, let refname): return refname
        }
    }
}
