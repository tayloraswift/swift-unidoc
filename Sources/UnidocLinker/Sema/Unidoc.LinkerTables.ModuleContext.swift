import SymbolGraphs
import Symbols
import Unidoc

extension Unidoc.LinkerTables {
    struct ModuleContext {
        let culture: SymbolGraph.Culture
        let symbol: Symbol.Module
        let id: Unidoc.Scalar
    }
}
