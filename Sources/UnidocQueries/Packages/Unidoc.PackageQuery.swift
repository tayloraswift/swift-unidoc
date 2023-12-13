import SymbolGraphs
import UnidocDB
import UnidocRecords

extension Unidoc
{
    public
    typealias PackageQuery = AliasResolutionQuery<
        UnidocDatabase.PackageAliases,
        UnidocDatabase.Packages>
}
