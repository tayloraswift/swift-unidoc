@frozen public
struct FNV24:Equatable, Hashable, Sendable
{
    public
    let value:UInt32

    @inlinable internal
    init(value:UInt32)
    {
        self.value = value
    }
}
extension FNV24:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        .init(self.value, radix: 36, uppercase: true)
    }
}
extension FNV24:LosslessStringConvertible
{
    @inlinable public
    init?(_ description:String)
    {
        self.init(description[...])
    }
}
extension FNV24
{
    @inlinable public
    init?(_ string:Substring, radix:Int = 36)
    {
        if  let value:UInt32 = .init(string, radix: radix),
            0 ... 0x00_ff_ff_ff ~= value
        {
            self.init(value: value)
        }
        else
        {
            return nil
        }
    }

    //  https://en.wikipedia.org/wiki/Fowler%E2%80%93Noll%E2%80%93Vo_hash_function
    @inlinable public
    init(hashing string:String)
    {
        let full:UInt32 = string.utf8.reduce(2166136261) { ($0 &* 16777619) ^ .init($1) }
        self.init(value: (full >> 24) ^ (full & 0x00_ff_ff_ff))
    }
}
