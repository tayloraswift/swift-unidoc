import SemanticVersions
import SymbolGraphs

extension SymbolGraphMetadata
{
    /// A suitable filename for the associated symbol graph archive.
    var filename:String
    {
        switch (self.package, self.commit?.refname)
        {
        case (.swift, _):
            "swift@\(self.swift).bson"

        case (let package, nil):
            "\(package).bson"

        case (let package, let refname?):
            "\(package)@\(refname).bson"
        }
    }
}
