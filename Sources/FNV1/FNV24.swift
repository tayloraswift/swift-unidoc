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

    @inlinable public
    init(truncating extended:Extended)
    {
        self.init(value: extended.value >> 8)
    }

    @inlinable public
    init(folding fnv32:FNV32)
    {
        self.init(truncating: fnv32.folded)
    }

    @inlinable public
    init(hashing string:String)
    {
        self.init(folding: .init(hashing: string))
    }
}
extension FNV24
{
    @inlinable public
    var min:Extended
    {
        .init(value: self.value << 8)
    }
    @inlinable public
    var max:Extended
    {
        .init(value: self.value << 8 | 0x00_00_00_ff)
    }
}
