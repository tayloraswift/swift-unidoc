import BSONDecoding
import BSONEncoding
import PackageGraphs
import SemanticVersions

extension SymbolGraph
{
    @frozen public
    struct Dependency:Equatable, Sendable
    {
        public
        let package:PackageIdentifier
        public
        let requirement:Range<SemanticVersion>?
        public
        let revision:Repository.Revision
        public
        let ref:SemanticRef

        @inlinable public
        init(package:PackageIdentifier,
            requirement:Range<SemanticVersion>?,
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
extension SymbolGraph.Dependency
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
extension SymbolGraph.Dependency:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKeys>)
    {
        bson[.package] = self.package

        if  let requirement:Range<SemanticVersion> = self.requirement
        {
            bson[.requirement_lower] = requirement.lowerBound
            bson[.requirement_upper] = requirement.upperBound
        }

        bson[.revision] = self.revision
        bson[.ref] = self.ref
    }
}
extension SymbolGraph.Dependency:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>) throws
    {
        let requirement:Range<SemanticVersion>?
        if  let lower:SemanticVersion = try bson[.requirement_lower]?.decode()
        {
            requirement = try lower ..< bson[.requirement_upper].decode()
        }
        else
        {
            requirement = nil
        }

        self.init(package: try bson[.package].decode(),
            requirement: requirement,
            revision: try bson[.revision].decode(),
            ref: try bson[.ref].decode())
    }
}
