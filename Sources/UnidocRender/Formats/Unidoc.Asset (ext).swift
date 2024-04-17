import SemanticVersions
import UnidocAssets

extension Unidoc.Asset
{
    @inlinable public
    func path(prepending version:MajorVersion) -> String
    {
        self.versioned ? "/asset/\(version)/\(self)" : "/asset/\(self)"
    }
}
