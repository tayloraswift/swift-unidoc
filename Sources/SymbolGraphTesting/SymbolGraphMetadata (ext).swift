import SemanticVersions
import SymbolGraphs

extension SymbolGraphMetadata
{
    /// A suitable filename for the associated symbol graph archive.
    var filename:String
    {
        switch (self.package, self.swift, self.commit?.refname)
        {
        case (.swift, nil, _):
            return "swift.bson"

        case (.swift, let version?, _):
            return "swift@\(version).bson"

        case (let package, _, nil):
            return "\(package).bson"

        case (let package, _, let refname?):
            return "\(package)@\(refname).bson"
        }
    }
}
