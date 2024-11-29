import SemanticVersions
import SymbolGraphs
import Symbols
import UnidocRecords

extension Unidoc
{
    public
    protocol GraphLinker
    {
        func link(
            documentation:SymbolGraphObject<Edition>,
            dependencies:[SymbolGraphObject<Edition>],
            dependencyMetadata:[EditionMetadata?],
            latestRelease:Edition?,
            thisRelease:PatchVersion?,
            as volume:Symbol.Volume,
            in realm:Realm?) -> Mesh
    }
}
