import PackageGraphs
import PackageMetadata
import SymbolGraphParts
import SymbolGraphs
import Symbols
import System

struct Artifacts
{
    let cultures:[Culture]
    var root:Symbol.FileBase?

    init(cultures:[Culture], root:Symbol.FileBase? = nil)
    {
        self.cultures = cultures
        self.root = root
    }
}
