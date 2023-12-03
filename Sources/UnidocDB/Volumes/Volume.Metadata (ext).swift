import UnidocRecords
import MongoQL

extension Volume.Metadata:MongoMasterCodingModel
{
}
extension Volume.Metadata
{
    public static
    func names(_ project:inout Mongo.ProjectionDocument)
    {
        project[Volume.Metadata[.id]] = true
        project[Volume.Metadata[.package]] = true
        project[Volume.Metadata[.version]] = true
        project[Volume.Metadata[.refname]] = true
        project[Volume.Metadata[.display]] = true
        project[Volume.Metadata[.latest]] = true
        project[Volume.Metadata[.realm]] = true
        project[Volume.Metadata[.patch]] = true
        project[Volume.Metadata[.api]] = true
    }
}
