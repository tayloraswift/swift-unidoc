import BSONEncoding
import UnidocAnalysis
import UnidocRecords

extension Records
{
    struct Groups<Latest> where Latest:BSONEncodable
    {
        let base:[Record.Group]
        let latest:Latest

        init(_ base:[Record.Group], latest:Latest)
        {
            self.base = base
            self.latest = latest
        }
    }
}
extension Records.Groups:Sendable where Latest:Sendable
{
}
extension Records.Groups:RandomAccessCollection
{
    var startIndex:Int { self.base.startIndex }
    var endIndex:Int { self.base.endIndex }

    subscript(index:Int) -> Element
    {
        .init(self.base[index], latest: self.latest)
    }
}
