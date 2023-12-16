@frozen public
struct FNV32:Equatable, Hashable, Sendable
{
    public
    let value:UInt32

    @inlinable internal
    init(value:UInt32)
    {
        self.value = value
    }
}
extension FNV32:RawRepresentable
{
    @inlinable public
    init(rawValue:Int32)
    {
        self.init(value: .init(bitPattern: rawValue))
    }
    @inlinable public
    var rawValue:Int32 { .init(bitPattern: self.value) }
}
extension FNV32
{
    //  https://en.wikipedia.org/wiki/Fowler%E2%80%93Noll%E2%80%93Vo_hash_function
    @inlinable public
    init(hashing string:String)
    {
        self.init(value: string.utf8.reduce(2166136261) { ($0 &* 16777619) ^ .init($1) })
    }
}
extension FNV32
{
    @inlinable public
    var folded:FNV24.Extended
    {
        let fold:UInt32 = self.value >> 24
        return .init(value: (self.value ^ fold) << 8 | fold)
    }

    @inlinable public static
    func recover(from folded:FNV24.Extended) -> Self
    {
        let fold:UInt32 = folded.value & 0x00_00_00_ff
        return .init(value: (fold << 24 | folded.value >> 8) ^ fold)
    }
}
