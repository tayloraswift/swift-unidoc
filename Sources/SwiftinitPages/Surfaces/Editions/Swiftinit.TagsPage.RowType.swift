import SHA1
import SemanticVersions

extension Swiftinit.TagsPage
{
    enum RowType
    {
        case tagged(String, SHA1?, PatchVersion, release:Bool)
        case tagless
    }
}
