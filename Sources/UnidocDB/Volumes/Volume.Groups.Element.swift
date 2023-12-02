import BSON
import Unidoc
import UnidocRecords

extension Volume.Groups
{
    struct Element
    {
        let base:Volume.Group
        let latest:Latest

        init(_ base:Volume.Group, latest:Latest)
        {
            self.base = base
            self.latest = latest
        }
    }
}
extension Volume.Groups.Element:Sendable where Latest:Sendable
{
}
extension Volume.Groups.Element:Identifiable
{
    var id:Unidoc.Scalar { self.base.id }
}
extension Volume.Groups.Element:BSONDocumentEncodable
{
    func encode(to bson:inout BSON.DocumentEncoder<Volume.Group.CodingKey>)
    {
        self.base.encode(to: &bson)

        bson[.latest] = self.latest
    }
}
