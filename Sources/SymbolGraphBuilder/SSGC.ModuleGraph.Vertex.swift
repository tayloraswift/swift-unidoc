import SymbolGraphs
import Symbols

extension SSGC.ModuleGraph
{
    struct Vertex:Identifiable
    {
        let id:SSGC.PackageGraph.Vertex
        let layout:SSGC.ModuleLayout

        private
        init(id:SSGC.PackageGraph.Vertex, layout:SSGC.ModuleLayout)
        {
            self.id = id
            self.layout = layout
        }
    }
}
extension SSGC.ModuleGraph.Vertex
{
    init(module layout:SSGC.ModuleLayout, in package:Symbol.Package)
    {
        self.init(id: .init(package: package, module: layout.module.id), layout: layout)
    }
}
