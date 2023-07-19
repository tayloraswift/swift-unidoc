import BSONEncoding
import Unidoc

extension Records.Extensions
{
    @frozen public
    struct Element
    {
        public
        let base:Record.Extension
        public
        let latest:Latest

        @inlinable internal
        init(_ base:Record.Extension, latest:Latest)
        {
            self.base = base
            self.latest = latest
        }
    }
}
extension Records.Extensions.Element:Sendable where Latest:Sendable
{
}
extension Records.Extensions.Element:Identifiable
{
    @inlinable public
    var id:Unidoc.Scalar { self.base.id }
}
extension Records.Extensions.Element:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<Record.Extension.CodingKey>)
    {
        self.base.encode(to: &bson)

        bson[.latest] = self.latest
    }
}
