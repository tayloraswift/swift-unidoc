import LexicalPaths
import SymbolGraphs

extension Unidoc {
    /// A sort priority that compares the fully-qualified names of declarations.
    enum LexicalPriority: Equatable, Comparable {
        case available  (UnqualifiedPath, Int32)
        case removed    (UnqualifiedPath, Int32)
    }
}
extension Unidoc.LexicalPriority: Unidoc.SortPriority {
    static func of(decl: SymbolGraph.Decl, at index: Int32) -> Self? {
        decl.signature.availability.isGenerallyRecommended
            ? .available(decl.path, index)
            : .removed(decl.path, index)
    }
}
