import BSON

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
extension Unidoc.PackageLicense
{
    /// Indicates if the license is (impressionistically) free or not. This is not legal advice!
    @inlinable public
    var free:Bool
    {
        switch self.spdx
        {
        case    "NOASSERTION",
                "NONE":
            false

        //  We don’t know enough about licenses to know if they are free or not, and
        //  Swiftinit does not provide legal advice.
        default:
            true
        }
    }
}
extension Unidoc.PackageLicense
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
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(spdx: try bson[.spdx].decode(), name: try bson[.name].decode())
    }
}
