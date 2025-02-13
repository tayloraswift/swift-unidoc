import SymbolGraphs
import Symbols

extension SSGC.ModuleGraph
{
    final
    class Node:Identifiable
    {
        let id:NodeIdentifier
        let layout:SSGC.ModuleLayout

        private
        init(id:NodeIdentifier, layout:SSGC.ModuleLayout)
        {
            self.id = id
            self.layout = layout
        }
    }
}
extension SSGC.ModuleGraph.Node
{
    convenience
    init(module layout:SSGC.ModuleLayout, in package:Symbol.Package)
    {
        self.init(id: .init(package: package, module: layout.module.id), layout: layout)
    }
}
