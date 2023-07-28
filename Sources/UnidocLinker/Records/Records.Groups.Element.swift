import BSONEncoding
import Unidoc
import UnidocRecords

extension Records.Groups
{
    @frozen public
    struct Element
    {
        public
        let base:Record.Group
        public
        let latest:Latest

        @inlinable internal
        init(_ base:Record.Group, latest:Latest)
        {
            self.base = base
            self.latest = latest
        }
    }
}
extension Records.Groups.Element:Sendable where Latest:Sendable
{
}
extension Records.Groups.Element:Identifiable
{
    @inlinable public
    var id:Unidoc.Scalar { self.base.id }
}
extension Records.Groups.Element:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<Record.Group.CodingKey>)
    {
        self.base.encode(to: &bson)

        bson[.latest] = self.latest
    }
}
