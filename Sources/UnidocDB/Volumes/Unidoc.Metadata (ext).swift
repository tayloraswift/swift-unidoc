import UnidocRecords
import MongoQL

extension Unidoc.VolumeMetadata:MongoMasterCodingModel
{
}
extension Unidoc.VolumeMetadata
{
    public static
    func names(_ project:inout Mongo.ProjectionDocument)
    {
        project[Unidoc.VolumeMetadata[.id]] = true
        project[Unidoc.VolumeMetadata[.package]] = true
        project[Unidoc.VolumeMetadata[.version]] = true
        project[Unidoc.VolumeMetadata[.refname]] = true
        project[Unidoc.VolumeMetadata[.display]] = true
        project[Unidoc.VolumeMetadata[.latest]] = true
        project[Unidoc.VolumeMetadata[.realm]] = true
        project[Unidoc.VolumeMetadata[.patch]] = true
        project[Unidoc.VolumeMetadata[.abi]] = true
    }
}
