import PackageGraphs
import System

extension PackageBuild
{
    /// Stores information about the source files for a package.
    struct Sources
    {
        let modules:[Module]

        private
        init(modules:[Module])
        {
            self.modules = modules
        }
    }
}
extension PackageBuild.Sources
{
    init(scanning package:borrowing PackageNode) throws
    {
        let root:FilePath = .init(package.root.path)
        self.init(modules: try package.modules.indices.map
        {
            try .init(scanning: package.modules[$0], exclude: package.exclude[$0], root: root)
        })
    }
}
extension PackageBuild.Sources
{
    func yield(include:inout [FilePath])
    {
        for module:Module in self.modules
        {
            include += module.include
        }
    }
}
