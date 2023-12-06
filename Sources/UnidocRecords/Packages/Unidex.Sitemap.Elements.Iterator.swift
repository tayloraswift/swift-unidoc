extension Unidex.Sitemap.Elements
{
    @frozen public
    struct Iterator
    {
        @usableFromInline internal
        let bytes:[UInt8]
        @usableFromInline internal
        var index:Int

        @inlinable internal
        init(bytes:[UInt8])
        {
            self.bytes = bytes
            self.index = bytes.startIndex
        }
    }
}
extension Unidex.Sitemap.Elements.Iterator:IteratorProtocol
{
    @inlinable public mutating
    func next() -> Volume.Shoot?
    {
        guard
        let i:Int = self.bytes[self.index...].firstIndex(of: 0x0A)
        else
        {
            return nil
        }
        defer
        {
            self.index = self.bytes.index(after: i)
        }

        return .deserialize(from: self.bytes[self.index ..< i])
    }
}
