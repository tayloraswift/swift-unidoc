import BSONDecoding
import BSONEncoding
import ModuleGraphs
import SemanticVersions
import SymbolGraphs
import Unidoc

extension Record
{
    @frozen public
    struct Zone:Equatable, Sendable
    {
        public
        let id:Unidoc.Scalar

        public
        let package:PackageIdentifier
        public
        let version:String

        public
        let recency:SemanticVersion?

        public
        let min:Unidoc.Scalar
        public
        let max:Unidoc.Scalar

        @inlinable public
        init(id:Unidoc.Scalar,
            package:PackageIdentifier,
            version:String,
            recency:SemanticVersion?,
            min:Unidoc.Scalar,
            max:Unidoc.Scalar)
        {
            self.id = id
            self.package = package
            self.version = version
            self.recency = recency
            self.min = min
            self.max = max
        }
    }
}
extension Record.Zone
{
    init(_ zone:Unidoc.Zone, package:PackageIdentifier, ref:SemanticRef?)
    {
        let version:String
        let recency:SemanticVersion?
        switch ref
        {
        case .version(let semver)?:
            version = "\(semver)"
            recency = semver

        case .unstable(let name)?:
            version = name
            recency = nil

        case nil:
            version = "$anonymous"
            recency = nil
        }

        self.init(id: zone + nil,
            package: package,
            version: version,
            recency: recency,
            min: zone.min,
            max: zone.max)
    }
}
extension Record.Zone
{
    public
    typealias CodingKeys = Record.CodingKeys
}
extension Record.Zone:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKeys>)
    {
        bson[.id] = self.id
        bson[.package] = self.package
        bson[.version] = self.version
        bson[.recency] = self.recency
        bson[.min] = self.min
        bson[.max] = self.max
    }
}
extension Record.Zone:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(id: try bson[.id].decode(),
            package: try bson[.package].decode(),
            version: try bson[.version].decode(),
            recency: try bson[.recency]?.decode(),
            min: try bson[.min].decode(),
            max: try bson[.max].decode())
    }
}
