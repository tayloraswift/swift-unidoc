import SymbolGraphs
import Symbols
import Unidoc

extension SymbolGraph
{
    struct NamespaceContext<ID>
    {
        let context:SymbolGraph.ModuleContext
        let culture:Unidoc.Scalar
        let module:Symbol.Module
        let id:ID

        init(context:SymbolGraph.ModuleContext,
            culture:Unidoc.Scalar,
            module:Symbol.Module,
            id:ID)
        {
            self.context = context
            self.culture = culture
            self.module = module
            self.id = id
        }
    }
}
extension SymbolGraph.NamespaceContext<Void>
{
    init(context:SymbolGraph.ModuleContext,
        culture:Unidoc.Scalar,
        module:Symbol.Module)
    {
        self.init(context: context, culture: culture, module: module, id: ())
    }
}
extension SymbolGraph.NamespaceContext
{
    var c:Int { .init(self.culture.citizen) }
}
