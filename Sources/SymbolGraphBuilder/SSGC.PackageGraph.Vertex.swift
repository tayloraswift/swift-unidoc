import Symbols

extension SSGC.PackageGraph
{
    struct Vertex:Equatable, Hashable
    {
        let package:Symbol.Package
        let module:Symbol.Module

        init(package:Symbol.Package, module:Symbol.Module)
        {
            self.package = package
            self.module = module
        }
    }
}
extension SSGC.PackageGraph.Vertex:Comparable
{
    static func < (a:Self, b:Self) -> Bool
    {
        (a.package, a.module) < (b.package, b.module)
    }
}
