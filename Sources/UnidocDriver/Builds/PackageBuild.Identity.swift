import ModuleGraphs

extension PackageBuild
{
    @frozen public
    enum Identity
    {
        case unversioned(PackageIdentifier)
        case versioned(Repository.Pin)
    }
}
