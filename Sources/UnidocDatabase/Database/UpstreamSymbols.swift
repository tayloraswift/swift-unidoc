import ModuleGraphs
import SymbolGraphs
import Symbols

/// A combined mapping of symbols to global addresses across all upstream dependencies.
/// Within a build tree, we assume module names are unique, which implies that symbol
/// manglings should never collide.
struct UpstreamSymbols
{
    var scalars:[ScalarSymbol: GlobalAddress]
    var modules:[ModuleIdentifier: GlobalAddress]

    init()
    {
        self.scalars = [:]
        self.modules = [:]
    }
}
