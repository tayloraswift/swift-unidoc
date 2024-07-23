import PackageGraphs
import SymbolGraphs
import Symbols
import System

extension SSGC.PackageSources
{
    /// Stores information about the source files for a package.
    struct Layout
    {
        var cultures:[SSGC.NominalSources]
        let root:SSGC.PackageRoot

        private
        init(cultures:[SSGC.NominalSources] = [], root:SSGC.PackageRoot)
        {
            self.cultures = cultures
            self.root = root
        }
    }
}
extension SSGC.PackageSources.Layout
{
    init(scanning graph:borrowing SSGC.ModuleGraph) throws
    {
        self.init(root: .init(normalizing: graph.package.root))

        let count:[SSGC.NominalSources.DefaultDirectory: Int] = graph.package.modules.reduce(
            into: [:])
        {
            if  case nil = $1.location,
                let directory:SSGC.NominalSources.DefaultDirectory = .init(for: $1.type)
            {
                $0[directory, default: 0] += 1
            }
        }

        var _ignore:[FilePath.Directory] = []

        for i:Int in graph.package.modules.indices
        {
            let module:SymbolGraph.Module = graph.package.modules[i]
            let dependencies:[SymbolGraph.Module] = try graph.dependencies(of: module)

            self.cultures.append(try .init(
                include: &_ignore,
                exclude: graph.package.exclude[i],
                package: self.root,
                dependencies: dependencies,
                module: module,
                count: count))
        }
    }
}
