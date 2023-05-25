import ModuleGraphs
import System

extension Artifacts
{
    @frozen public
    struct IncludePaths
    {
        public
        var paths:[FilePath]

        @inlinable public
        init(paths:[FilePath])
        {
            self.paths = paths
        }
    }
}
extension Artifacts.IncludePaths:ExpressibleByArrayLiteral
{
    @inlinable public
    init(arrayLiteral:FilePath...)
    {
        self.init(paths: arrayLiteral)
    }
}
extension Artifacts.IncludePaths
{
    init(root:Repository.Root, configuration:Toolchain.BuildConfiguration)
    {
        self.init(paths: [.init(root.path) / ".build" / "\(configuration)"])
    }

    mutating
    func add(from sources:[Artifacts.Sources])
    {
        for sources:Artifacts.Sources in sources where sources.language != .swift
        {
            //  C/C++ modules often contains headers needed to generate
            //  symbolgraph parts.
            if  let path:FilePath = sources.path
            {
                self.paths.append(path)
            }
        }
    }
}
