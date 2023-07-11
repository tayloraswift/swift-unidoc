import ModuleGraphs
import SemanticVersions

extension PackageIdentifier
{
    func filename(version:AnyVersion?) -> String
    {
        version.map { "\(self)@\($0).ss" } ?? "\(self).ss"
    }
}
