import ModuleGraphs
import SemanticVersions
import SymbolGraphs
import Unidoc
import UnidocRecords

extension Record.Zone
{
    init(_ zone:Unidoc.Zone, metadata:__shared SymbolGraphMetadata)
    {
        self.init(id: zone,
            package: metadata.package,
            version: metadata.version?.description ?? "$anonymous",
            refname: metadata.refname,
            display: metadata.display,
            github: metadata.github,
            latest: true,
            patch: metadata.version?.stable?.release)
    }
}
