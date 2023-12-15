import SemanticVersions

@available(*, deprecated, renamed: "Swiftinit.Asset")
public
typealias StaticAsset = Swiftinit.Asset

extension Swiftinit.Asset
{
    @inlinable public
    func path(prepending version:MinorVersion) -> String
    {
        switch self.versioning
        {
        case .none:     "/asset/\(self)"
        case .major:    "/asset/\(version.major)/\(self)"
        case .minor:    "/asset/\(version)/\(self)"
        }
    }
}
