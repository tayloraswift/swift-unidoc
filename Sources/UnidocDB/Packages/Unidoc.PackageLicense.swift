import BSON
import MongoQL

extension Unidoc
{
    @frozen public
    struct PackageLicense:Equatable, Sendable
    {
        public
        let spdx:String
        public
        let name:String

        @inlinable public
        init(spdx:String, name:String)
        {
            self.spdx = spdx
            self.name = name
        }
    }
}
extension Unidoc.PackageLicense:MongoMasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case spdx = "I"
        case name = "N"
    }
}
extension Unidoc.PackageLicense:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.spdx] = self.spdx
        bson[.name] = self.name
    }
}
extension Unidoc.PackageLicense:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(spdx: try bson[.spdx].decode(), name: try bson[.name].decode())
    }
}
