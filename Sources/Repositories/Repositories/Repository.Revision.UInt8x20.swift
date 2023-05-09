extension Repository.Revision
{
    @frozen public
    struct UInt8x20:Sendable
    {
        @usableFromInline internal
        typealias Storage = (UInt32, UInt32, UInt32, UInt32, UInt32)

        @usableFromInline internal
        var storage:Storage

        @inlinable internal
        init(storage:Storage = (0, 0, 0, 0, 0))
        {
            self.storage = storage
        }
    }
}
extension Repository.Revision.UInt8x20:Equatable
{
    @inlinable public static
    func == (lhs:Self, rhs:Self) -> Bool
    {
        lhs.storage == rhs.storage
    }
}
extension Repository.Revision.UInt8x20:Hashable
{
    @inlinable public
    func hash(into hasher:inout Hasher)
    {
        for byte:UInt8 in self
        {
            byte.hash(into: &hasher)
        }
    }
}
extension Repository.Revision.UInt8x20:RandomAccessCollection
{
    @inlinable public
    var startIndex:Int
    {
        0
    }
    @inlinable public
    var endIndex:Int
    {
        MemoryLayout<Storage>.size
    }
    @inlinable public
    subscript(index:Int) -> UInt8
    {
        get
        {
            precondition(self.indices ~= index, "index out of range")
            return withUnsafeBytes(of: self.storage) { $0[index] }
        }
        set(value)
        {
            precondition(self.indices ~= index, "index out of range")
            withUnsafeMutableBytes(of: &self.storage) { $0[index] = value }
        }
    }
}
