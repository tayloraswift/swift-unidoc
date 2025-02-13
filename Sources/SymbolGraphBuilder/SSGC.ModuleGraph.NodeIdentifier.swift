import Symbols

extension SSGC.ModuleGraph
{
    struct NodeIdentifier:Equatable, Hashable
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
extension SSGC.ModuleGraph.NodeIdentifier:Comparable
{
    static func < (a:Self, b:Self) -> Bool
    {
        (a.package, a.module) < (b.package, b.module)
    }
}
