import BSONEncoding
import UnidocRecords

extension Volume
{
    struct Groups<Latest> where Latest:BSONEncodable
    {
        let base:[Group]
        let latest:Latest

        init(_ base:[Group], latest:Latest)
        {
            self.base = base
            self.latest = latest
        }
    }
}
extension Volume.Groups:Sendable where Latest:Sendable
{
}
extension Volume.Groups:RandomAccessCollection
{
    var startIndex:Int { self.base.startIndex }
    var endIndex:Int { self.base.endIndex }

    subscript(index:Int) -> Element
    {
        .init(self.base[index], latest: self.latest)
    }
}
