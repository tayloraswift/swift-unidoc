import ModuleGraphs
import SymbolGraphs
import Symbols

/// A combined mapping of symbols to global scalars across all upstream dependencies.
/// Within a build tree, we assume module names are unique, which implies that symbol
/// manglings should never collide.
struct UpstreamScalars
{
    var cultures:[ModuleIdentifier: Scalar96]
    var citizens:[ScalarSymbol: Scalar96]

    init()
    {
        self.cultures = [:]
        self.citizens = [:]
    }
}
