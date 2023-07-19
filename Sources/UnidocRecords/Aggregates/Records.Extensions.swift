import BSONEncoding

extension Records
{
    @frozen public
    struct Extensions<Latest> where Latest:BSONEncodable
    {
        @usableFromInline internal
        let base:[Record.Extension]
        public
        let latest:Latest

        @inlinable internal
        init(_ base:[Record.Extension], latest:Latest)
        {
            self.base = base
            self.latest = latest
        }
    }
}
extension Records.Extensions:Sendable where Latest:Sendable
{
}
extension Records.Extensions:RandomAccessCollection
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
