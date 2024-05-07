import SemanticVersions
import SHA1

extension Unidoc.TagsTable.Row
{
    struct Tagged
    {
        let commit:SHA1?
        let series:Unidoc.VersionSeries?
        let patch:PatchVersion
        let name:String

        init(commit:SHA1?, series:Unidoc.VersionSeries?, patch:PatchVersion, name:String)
        {
            self.commit = commit
            self.series = series
            self.patch = patch
            self.name = name
        }
    }
}
