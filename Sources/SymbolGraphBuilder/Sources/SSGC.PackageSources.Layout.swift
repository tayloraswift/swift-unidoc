import PackageGraphs
import System

extension SSGC.PackageSources
{
    /// Stores information about the source files for a package.
    struct Layout
    {
        var cultures:[SSGC.NominalSources]
        let root:SSGC.PackageRoot

        init(cultures:[SSGC.NominalSources] = [], root:SSGC.PackageRoot)
        {
            self.cultures = cultures
            self.root = root
        }
    }
}
extension SSGC.PackageSources.Layout
{
    init(scanning package:borrowing PackageNode, include:inout [FilePath.Directory]) throws
    {
        self.init(root: .init(normalizing: package.root))

        let count:[SSGC.NominalSources.DefaultDirectory: Int] = package.modules.reduce(
            into: [:])
        {
            if  case nil = $1.location,
                let directory:SSGC.NominalSources.DefaultDirectory = .init(for: $1.type)
            {
                $0[directory, default: 0] += 1
            }
        }
        for i:Int in package.modules.indices
        {
            self.cultures.append(try .init(
                include: &include,
                exclude: package.exclude[i],
                package: self.root,
                module: package.modules[i],
                count: count))
        }
    }
}
