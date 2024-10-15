extension IP
{
    /// A native SwiftNIO `IPv4Address` is reference counted and resilient, and we
    /// would rather pass around an inline value type.
    @frozen public
    struct V4:Equatable, Hashable, Sendable
    {
        /// The raw address, in big-endian byte order.
        public
        var storage:UInt32

        @inlinable public
        init(storage:UInt32)
        {
            self.storage = storage
        }
    }
}
extension IP.V4
{
    @inlinable public
    static var localhost:Self { .init(storage: (0x7F_00_00_01 as UInt32).bigEndian) }

    /// The logical value of the address. The high byte is the first octet.
    @inlinable public
    var value:UInt32 { UInt32.init(bigEndian: self.storage) }
}
extension IP.V4:Comparable
{
    @inlinable public static
    func < (a:Self, b:Self) -> Bool { a.storage < b.storage }
}
extension IP.V4:IP.Address
{
    @inlinable public static
    var bitWidth:UInt8 { 32 }

    @inlinable public static
    func & (a:Self, b:Self) -> Self
    {
        .init(storage: a.storage & b.storage)
    }

    @inlinable public static
    func / (self:Self, bits:UInt8) -> Self
    {
        let ones:UInt32 = ~0
        let mask:UInt32 = ones << (32 - bits)
        return .init(storage: self.storage & mask.bigEndian)
    }
}
extension IP.V4:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        withUnsafeBytes(of: self.storage) { "\($0[0]).\($0[1]).\($0[2]).\($0[3])" }
    }
}
extension IP.V4:LosslessStringConvertible
{
    @inlinable public
    init?(_ description:some StringProtocol)
    {
        guard
        var b:String.Index = description.firstIndex(of: "."),
        let a:UInt8 = .init(description[..<b])
        else
        {
            return nil
        }

        b = description.index(after: b)

        guard
        var c:String.Index = description[b...].firstIndex(of: "."),
        let b:UInt8 = .init(description[b ..< c])
        else
        {
            return nil
        }

        c = description.index(after: c)

        guard
        var d:String.Index = description[c...].firstIndex(of: "."),
        let c:UInt8 = .init(description[c ..< d])
        else
        {
            return nil
        }

        d = description.index(after: d)

        guard
        let d:UInt8 = .init(description[d...])
        else
        {
            return nil
        }

        let value:UInt32 =
            UInt32.init(a) << 24 |
            UInt32.init(b) << 16 |
            UInt32.init(c) <<  8 |
            UInt32.init(d)

        self.init(storage: value.bigEndian)
    }
}
