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
    init(scanning tree:borrowing SSGC.PackageTree, include:inout [FilePath.Directory]) throws
    {
        self.init(root: .init(normalizing: tree.sink.root))

        let count:[SSGC.NominalSources.DefaultDirectory: Int] = tree.sink.modules.reduce(
            into: [:])
        {
            if  case nil = $1.location,
                let directory:SSGC.NominalSources.DefaultDirectory = .init(for: $1.type)
            {
                $0[directory, default: 0] += 1
            }
        }
        for i:Int in tree.sink.modules.indices
        {
            let module:SymbolGraph.Module = tree.sink.modules[i]

            var dependencies:[SymbolGraph.Module] = module.dependencies.modules.map
            {
                tree.sink.modules[$0]
            }
            for product:Symbol.Product in module.dependencies.products
            {
                dependencies += tree.productPartitions[product] ?? []
            }

            self.cultures.append(try .init(
                include: &include,
                exclude: tree.sink.exclude[i],
                package: self.root,
                dependencies: dependencies,
                module: module,
                count: count))
        }
    }
}
