import SymbolGraphs
import Symbols
import Unidoc
import UnidocRecords

extension Unidoc.LinkerTables {
    struct ModuleView {
        let namespaces: [Symbol.Module]
        let cultures: [SymbolGraph.Culture]
        let edition: Unidoc.Edition

        init(
            namespaces: [Symbol.Module],
            cultures: [SymbolGraph.Culture],
            edition: Unidoc.Edition
        ) {
            self.namespaces = namespaces
            self.cultures = cultures
            self.edition = edition
        }
    }
}
extension Unidoc.LinkerTables.ModuleView: RandomAccessCollection {
    var startIndex: Int { self.cultures.startIndex }
    var endIndex: Int { self.cultures.endIndex }

    subscript(culture: Int) -> Unidoc.LinkerTables.ModuleContext {
        .init(
            culture: self.cultures[culture],
            symbol: self.namespaces[culture],
            id: self.edition + culture
        )
    }
}
