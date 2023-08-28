import SemanticVersions
import SymbolGraphs

extension SymbolGraphMetadata
{
    @inlinable public
    var volume:VolumeIdentifier
    {
        .init(package: self.package, version: self.version?.description ?? "$unversioned")
    }
}
