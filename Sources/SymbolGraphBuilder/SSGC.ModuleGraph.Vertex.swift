import SymbolGraphs
import Symbols

extension SSGC.ModuleGraph
{
    struct Vertex:Identifiable
    {
        let id:SSGC.PackageGraph.Vertex
        let module:SymbolGraph.Module

        private
        init(id:SSGC.PackageGraph.Vertex, module:SymbolGraph.Module)
        {
            self.id = id
            self.module = module
        }
    }
}
extension SSGC.ModuleGraph.Vertex
{
    init(module:SymbolGraph.Module, in package:Symbol.Package)
    {
        self.init(id: .init(package: package, module: module.id), module: module)
    }
}
