import BSONDecoding
import BSONEncoding
import MongoQL

extension PackageDatabase.Packages
{
    @frozen public
    struct Registration:Equatable, Hashable, Sendable
    {
        public
        let cell:Int32
        public
        let new:Bool

        @inlinable public
        init(cell:Int32, new:Bool)
        {
            self.cell = cell
            self.new = new
        }
    }
}
extension PackageDatabase.Packages.Registration:MongoMasterCodingModel
{
    public
    enum CodingKey:String
    {
        case cell
        case new
    }
}
extension PackageDatabase.Packages.Registration:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(cell: try bson[.cell].decode(), new: try bson[.new].decode())
    }
}
