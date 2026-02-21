import BSON
import SemanticVersions
import Unidoc
import UnidocRecords

extension Unidoc.DB.Volumes {
    struct PatchView: Equatable, Sendable {
        let id: Unidoc.Edition
        let patch: PatchVersion

        private init(id: Unidoc.Edition, patch: PatchVersion) {
            self.id = id
            self.patch = patch
        }
    }
}
extension Unidoc.DB.Volumes.PatchView: BSONDocumentDecodable {
    typealias CodingKey = Unidoc.VolumeMetadata.CodingKey

    init(bson: BSON.DocumentDecoder<CodingKey>) throws {
        self.init(id: try bson[.id].decode(), patch: try bson[.patch].decode())
    }
}
