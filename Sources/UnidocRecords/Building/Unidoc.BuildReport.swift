import BSON
import UnidocAPI

extension Unidoc
{
    @frozen public
    struct BuildReport:Equatable, Sendable
    {
        public
        let edition:Edition
        public
        var entered:BuildStage

        @inlinable public
        init(edition:Edition, entered:BuildStage)
        {
            self.edition = edition
            self.entered = entered
        }
    }
}
extension Unidoc.BuildReport
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case edition = "e"
        case entered = "E"
    }
}
extension Unidoc.BuildReport:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.edition] = self.edition
        bson[.entered] = self.entered
    }
}
extension Unidoc.BuildReport:BSONDocumentDecodable
{
    public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(edition: try bson[.edition].decode(), entered: try bson[.entered].decode())
    }
}
