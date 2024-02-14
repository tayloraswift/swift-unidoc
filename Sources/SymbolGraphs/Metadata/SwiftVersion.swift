import BSON
import SemanticVersions

@frozen public
struct SwiftVersion:Equatable, Sendable
{
    public
    let version:PatchVersion
    public
    let nightly:Nightly?

    @inlinable public
    init(version:PatchVersion, nightly:Nightly? = nil)
    {
        self.version = version
        self.nightly = nightly
    }
}
