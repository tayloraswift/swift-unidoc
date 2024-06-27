import BSON
import UnidocAPI

extension Unidoc
{
    @frozen public
    struct BuildReport:Equatable, Sendable
    {
        public
        let package:Package
        public
        var entered:BuildStage

        @inlinable public
        init(package:Package, entered:BuildStage)
        {
            self.package = package
            self.entered = entered
        }
    }
}
extension Unidoc.BuildReport
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case package = "P"
        case entered = "E"
    }
}
extension Unidoc.BuildReport:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.package] = self.package
        bson[.entered] = self.entered
    }
}
extension Unidoc.BuildReport:BSONDocumentDecodable
{
    public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(
            package: try bson[.package].decode(),
            entered: try bson[.entered].decode())
    }
}
