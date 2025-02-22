import MongoQL
import UnidocRecords

extension Unidoc.VolumeMetadata
{
    @frozen public
    struct NameFields:Mongo.ProjectionEncodable
    {
        @inlinable public
        init() {}

        @inlinable public
        func encode(to projection:inout Mongo.ProjectionEncoder<CodingKey>)
        {
            projection[.id] = true
            projection[.package] = true
            projection[.version] = true
            projection[.commit_name] = true
            projection[.display] = true
            projection[.latest] = true
            projection[.realm] = true
            projection[.patch] = true
            projection[.abi] = true
        }
    }
}
