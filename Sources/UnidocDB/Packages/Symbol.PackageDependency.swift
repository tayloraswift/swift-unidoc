import BSON
import MongoQL
import Symbols

extension Symbol {
    struct PackageDependency<Version> {
        let package: Package
        let version: Version

        init(package: Package, version: Version) {
            self.package = package
            self.version = version
        }
    }
}
extension Symbol.PackageDependency: Sendable where Version: Sendable {
}
extension Symbol.PackageDependency: Mongo.MasterCodingModel {
    enum CodingKey: String, Sendable {
        case package = "P"
        case version = "V"
    }
}
extension Symbol.PackageDependency: BSONDocumentEncodable, BSONEncodable
    where Version: BSONEncodable {
    func encode(to bson: inout BSON.DocumentEncoder<CodingKey>) {
        bson[.package] = package
        bson[.version] = version
    }
}
extension Symbol.PackageDependency: BSONDocumentDecodable, BSONDecodable
    where Version: BSONDecodable {
    init(bson: BSON.DocumentDecoder<CodingKey>) throws {
        self.init(package: try bson[.package].decode(), version: try bson[.version].decode())
    }
}
