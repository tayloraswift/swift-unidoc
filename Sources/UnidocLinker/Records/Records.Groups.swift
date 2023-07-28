import BSONEncoding
import UnidocRecords

extension Records
{
    @frozen public
    struct Groups<Latest> where Latest:BSONEncodable
    {
        @usableFromInline internal
        let base:[Record.Group]

        public
        let latest:Latest

        @inlinable internal
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
    @inlinable public
    var startIndex:Int { self.base.startIndex }
    @inlinable public
    var endIndex:Int { self.base.endIndex }

    @inlinable public
    subscript(index:Int) -> Element
    {
        .init(self.base[index], latest: self.latest)
    }
}
