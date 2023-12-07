import SymbolGraphs
import UnidocDB
import UnidocRecords

extension Unidex
{
    public
    typealias PackageQuery = AliasResolutionQuery<
        UnidocDatabase.PackageAliases,
        UnidocDatabase.Packages>
}
