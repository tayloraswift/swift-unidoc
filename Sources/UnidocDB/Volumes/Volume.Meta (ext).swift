import UnidocRecords
import MongoQL

extension Volume.Meta:MongoMasterCodingModel
{
}
extension Volume.Meta
{
    public static
    func names(_ project:inout Mongo.ProjectionDocument)
    {
        project[Volume.Meta[.id]] = true
        project[Volume.Meta[.package]] = true
        project[Volume.Meta[.version]] = true
        project[Volume.Meta[.refname]] = true
        project[Volume.Meta[.display]] = true
        project[Volume.Meta[.latest]] = true
        project[Volume.Meta[.realm]] = true
        project[Volume.Meta[.patch]] = true
        project[Volume.Meta[.api]] = true
    }
}
