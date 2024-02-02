import PackageGraphs
import PackageMetadata
import SymbolGraphParts
import SymbolGraphs
import Symbols
import System

@available(*, deprecated, renamed: "SPM.Artifacts")
public
typealias Artifacts = SPM.Artifacts

extension SPM
{
    public
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
}
