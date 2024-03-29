import SemanticVersions
import SHA1

extension Swiftinit.TagsTable.Row
{
    struct Tagged
    {
        let release:Bool
        let version:PatchVersion
        let commit:SHA1?
        let name:String
    }
}
