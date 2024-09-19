import PackageGraphs
import SymbolGraphs
import Symbols
import System_

extension SSGC
{
    /// Stores information about the source files for a package.
    struct PackageLayout
    {
        let cultures:[ModuleLayout]
        let root:PackageRoot

        private
        init(cultures:[ModuleLayout], root:PackageRoot)
        {
            self.cultures = cultures
            self.root = root
        }
    }
}
extension SSGC.PackageLayout
{
    init(scanning package:__shared PackageNode) throws
    {
        let root:SSGC.PackageRoot = .init(normalizing: package.root)
        let count:[SSGC.ModuleLayout.DefaultDirectory: Int] = package.modules.reduce(
            into: [:])
        {
            if  case nil = $1.location,
                let directory:SSGC.ModuleLayout.DefaultDirectory = .init(for: $1.type)
            {
                $0[directory, default: 0] += 1
            }
        }

        var cultures:[SSGC.ModuleLayout] = []
            cultures.reserveCapacity(package.modules.count)

        for i:Int in package.modules.indices
        {
            cultures.append(try .init(
                exclude: package.exclude[i],
                package: root,
                module: package.modules[i],
                count: count))
        }

        self.init(cultures: cultures, root: root)
    }
}
