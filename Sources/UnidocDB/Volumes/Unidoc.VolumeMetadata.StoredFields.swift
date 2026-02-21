import MongoQL
import UnidocRecords

extension Unidoc.VolumeMetadata {
    @frozen public struct StoredFields: Mongo.ProjectionEncodable {
        @inlinable public init() {}

        @inlinable public func encode(to projection: inout Mongo.ProjectionEncoder<CodingKey>) {
            projection[.id] = true
            projection[.dependencies] = true
            projection[.package] = true
            projection[.version] = true
            projection[.display] = true
            projection[.commit_name] = true
            projection[.commit_sha1] = true
            projection[.commit_date] = true
            projection[.patch] = true

            //  TODO: we only need this for top-level queries and
            //  foreign vertices!
            projection[.products] = true
            projection[.cultures] = true

            projection[.latest] = true
            projection[.realm] = true
            projection[.abi] = true
        }
    }
}
