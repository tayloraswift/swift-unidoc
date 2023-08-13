import BSONEncoding
import Unidoc
import UnidocAnalysis
import UnidocRecords

extension Records.Groups
{
    struct Element
    {
        let base:Record.Group
        let latest:Latest

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
    var id:Unidoc.Scalar { self.base.id }
}
extension Records.Groups.Element:BSONDocumentEncodable
{
    func encode(to bson:inout BSON.DocumentEncoder<Record.Group.CodingKey>)
    {
        self.base.encode(to: &bson)

        bson[.latest] = self.latest
    }
}
