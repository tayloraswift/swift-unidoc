import PackageGraphs
import System

/// Stores information about the source files for a package.
struct PackageSources
{
    let modules:[ModuleSources]

    private
    init(modules:[ModuleSources])
    {
        self.modules = modules
    }
}
extension PackageSources
{
    init(scanning package:__shared PackageNode) throws
    {
        let root:FilePath = .init(package.root.path)
        self.init(modules: try package.modules.indices.map
        {
            try .init(scanning: package.modules[$0], exclude: package.exclude[$0], root: root)
        })
    }
}
extension PackageSources
{
    func yield(include:inout [FilePath])
    {
        for module:ModuleSources in self.modules
        {
            include += module.include
        }
    }
}
