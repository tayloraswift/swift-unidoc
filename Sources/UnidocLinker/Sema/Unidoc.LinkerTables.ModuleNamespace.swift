import Symbols
import Unidoc

extension Unidoc.LinkerTables {
    struct ModuleNamespace {
        let culture: Unidoc.Scalar
        let colony: Unidoc.Scalar
        let symbol: Symbol.Module
    }
}
extension Unidoc.LinkerTables.ModuleNamespace {
    var cultureOffset: Int { .init(self.culture.citizen) }
}
