import SemanticVersions
import SHA1

extension Swiftinit.TagsPage
{
    enum RowType
    {
        case tagged(String, SHA1?, PatchVersion, release:Bool)
        case tagless
    }
}
