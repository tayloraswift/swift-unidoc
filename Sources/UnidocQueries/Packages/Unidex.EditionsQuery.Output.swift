import BSON
import MongoQL
import UnidocDB
import UnidocRecords

extension Unidex.EditionsQuery
{
    @frozen public
    struct Output:Equatable, Sendable
    {
        public
        var prereleases:[Facet]
        public
        var releases:[Facet]
        public
        var package:Unidex.Package

        @inlinable public
        init(prereleases:[Facet], releases:[Facet], package:Unidex.Package)
        {
            self.prereleases = prereleases
            self.releases = releases
            self.package = package
        }
    }
}
extension Unidex.EditionsQuery.Output:MongoMasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case prereleases
        case releases
        case package
    }
}
extension Unidex.EditionsQuery.Output:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            prereleases: try bson[.prereleases]?.decode() ?? [],
            releases: try bson[.releases]?.decode() ?? [],
            package: try bson[.package].decode())
    }
}
