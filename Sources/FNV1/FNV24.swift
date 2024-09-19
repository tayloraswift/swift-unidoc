@frozen public
struct FNV24:Equatable, Hashable, Sendable
{
    public
    let value:UInt32

    @inlinable
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
extension FNV24:Comparable
{
    @inlinable public
    static func < (a:FNV24, b:FNV24) -> Bool { a.value < b.value }
}
extension FNV24:RawRepresentable
{
    /// Because ``FNV24`` is a 24-bit value, it can also be represented as a signed 32-bit
    /// integer, and the ``Int32`` representation will exhibit the same sorting behavior.
    @inlinable public
    var rawValue:Int32 { .init(self.value) }

    @inlinable public
    init?(rawValue:Int32)
    {
        if  0 ... 0x00_ff_ff_ff ~= rawValue
        {
            self.init(value: .init(rawValue))
        }
        else
        {
            return nil
        }
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
