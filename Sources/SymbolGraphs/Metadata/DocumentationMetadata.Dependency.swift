import BSONDecoding
import BSONEncoding
import PackageGraphs
import SemanticVersions

extension DocumentationMetadata
{
    @frozen public
    struct Dependency:Equatable, Sendable
    {
        public
        let package:PackageIdentifier
        public
        let requirement:Repository.Requirement?
        public
        let revision:Repository.Revision
        public
        let ref:SemanticRef

        @inlinable public
        init(package:PackageIdentifier,
            requirement:Repository.Requirement?,
            revision:Repository.Revision,
            ref:SemanticRef)
        {
            self.package = package
            self.requirement = requirement
            self.revision = revision
            self.ref = ref
        }
    }
}
extension DocumentationMetadata.Dependency
{
    @frozen public
    enum CodingKeys:String
    {
        case package = "P"
        case requirement_lower = "L"
        case requirement_upper = "U"
        case revision = "H"
        case ref = "R"
    }
}
extension DocumentationMetadata.Dependency:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKeys>)
    {
        bson[.package] = self.package

        switch self.requirement
        {
        case nil:
            break

        case .exact(let version):
            bson[.requirement_lower] = version

        case .range(let versions):
            bson[.requirement_lower] = versions.lowerBound
            bson[.requirement_upper] = versions.upperBound
        }

        bson[.revision] = self.revision
        bson[.ref] = self.ref
    }
}
extension DocumentationMetadata.Dependency:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>) throws
    {
        let requirement:Repository.Requirement?
        switch
        (
            try bson[.requirement_lower]?.decode(to: SemanticVersion.self),
            try bson[.requirement_upper]?.decode(to: SemanticVersion.self)
        )
        {
        case (nil, _):
            requirement = nil

        case (let lower?, nil):
            requirement = .exact(lower)

        case (let lower?, let upper?):
            requirement = upper < lower ? nil : .range(lower ..< upper)
        }

        self.init(package: try bson[.package].decode(),
            requirement: requirement,
            revision: try bson[.revision].decode(),
            ref: try bson[.ref].decode())
    }
}
