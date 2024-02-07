import SemanticVersions

@available(*, deprecated, renamed: "Swiftinit.Asset")
public
typealias StaticAsset = Swiftinit.Asset

extension Swiftinit.Asset
{
    @inlinable public
    func path(prepending version:MajorVersion) -> String
    {
        self.versioned ? "/asset/\(version)/\(self)" : "/asset/\(self)"
    }
}
