import JSON
import PackageMetadata

extension PackageManifest
{
    init(parsing json:String) throws
    {
        try self.init(json: try JSON.Object.init(parsing: json))
    }
}
