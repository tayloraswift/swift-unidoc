extension IP
{
    /// A native SwiftNIO `IPv6Address` is reference counted and resilient, and we
    /// would rather pass around an inline value type.
    @frozen public
    struct V6:Sendable
    {
        /// The raw 128-bit address, in big-endian byte order. The byte at the lowest address is
        /// the high byte of the first hextet.
        ///
        /// The logical value of the tuple elements varies depending on the platform byte order.
        /// For example, printing the tuple elements will give different results on big-endian
        /// and little-endian platforms.
        public
        var storage:(UInt64, UInt64)

        @inlinable public
        init(storage:(UInt64, UInt64))
        {
            self.storage = storage
        }
    }
}
extension IP.V6
{
    /// Initializes an IPv6 address from a tuple of 32-bit words, with elements in big-endian
    /// byte order.
    @inlinable public
    init(storage:(UInt32, UInt32, UInt32, UInt32))
    {
        self = withUnsafeBytes(of: storage) { .copy(buffer: $0) }
    }

    /// Initializes an IPv6 address from a tuple of 16-bit words, with elements in big-endian
    /// byte order.
    @inlinable public
    init(storage:(UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16))
    {
        self = withUnsafeBytes(of: storage) { .copy(buffer: $0) }
    }

    /// Initializes an IPv6 address from 16-bit components, each in platform byte order.
    @inlinable public
    init(
        _ a:UInt16,
        _ b:UInt16,
        _ c:UInt16,
        _ d:UInt16,
        _ e:UInt16,
        _ f:UInt16,
        _ g:UInt16,
        _ h:UInt16)
    {
        self.init(storage:
        (
            a.bigEndian,
            b.bigEndian,
            c.bigEndian,
            d.bigEndian,
            e.bigEndian,
            f.bigEndian,
            g.bigEndian,
            h.bigEndian
        ))
    }
}
extension IP.V6
{
    @inlinable public
    init(v4:IP.V4)
    {
        self.init(storage: (0, 0, (0x0000_ffff as UInt32).bigEndian, v4.storage))
    }

    @inlinable public
    var v4:IP.V4?
    {
        guard
        self.storage.0 == 0
        else
        {
            return nil
        }

        return withUnsafeBytes(of: self.storage.1)
        {
            let subnet:(UInt32, UInt32) = $0.load(as: (UInt32, UInt32).self)
            if  subnet.0 == (0x0000_ffff as UInt32).bigEndian
            {
                return .init(storage: subnet.1)
            }
            else
            {
                return nil
            }
        }
    }
}
extension IP.V6
{
    @inlinable public
    static func copy(from bytes:some RandomAccessCollection<UInt8>) -> Self?
    {
        bytes.count == MemoryLayout<(UInt64, UInt64)>.size ? .copy(buffer: bytes) : nil
    }

    @inlinable
    static func copy(buffer:some RandomAccessCollection<UInt8>) -> Self
    {
        precondition(buffer.count == MemoryLayout<(UInt64, UInt64)>.size)

        return withUnsafeTemporaryAllocation(
            byteCount: MemoryLayout<(UInt64, UInt64)>.size,
            alignment: MemoryLayout<(UInt64, UInt64)>.alignment)
        {
            $0.copyBytes(from: buffer)
            return .init(storage: $0.load(as: (UInt64, UInt64).self))
        }
    }
}
extension IP.V6
{
    @inlinable public
    static var zero:Self { .init(storage: (0, 0)) }

    @inlinable public
    static var ones:Self { .init(storage: (~0, ~0)) }

    @inlinable public
    static var localhost:Self { .init(storage: (0, (1 as UInt64).bigEndian)) }

    /// The **logical** prefix address, in platform byte order. The high bits are the high byte
    /// of the first hextet.
    @inlinable public
    var _prefix:UInt64 { UInt64.init(bigEndian: self.storage.0) }
    /// The **logical** subnet address, in platform byte order. The high bits are the high byte
    /// of the fifth hextet.
    @inlinable public
    var _subnet:UInt64 { UInt64.init(bigEndian: self.storage.1) }

    /// The logical value of the address. The high bits of the first tuple element are the high
    /// byte of the first hextet.
    @inlinable public
    var value:(UInt64, UInt64) { (self._prefix, self._subnet) }
}
extension IP.V6:Equatable
{
    @inlinable public
    static func == (a:Self, b:Self) -> Bool { a.storage == b.storage }
}
extension IP.V6:Hashable
{
    @inlinable public
    func hash(into hasher:inout Hasher)
    {
        let value:(UInt64, UInt64) = self.value
        value.0.hash(into: &hasher)
        value.1.hash(into: &hasher)
    }
}
extension IP.V6:Comparable
{
    @inlinable public static
    func < (a:Self, b:Self) -> Bool { a.value < b.value }
}
extension IP.V6:IP.Address
{
    @inlinable public static
    var bitWidth:UInt8 { 128 }

    @inlinable public static
    func & (a:Self, b:Self) -> Self
    {
        .init(storage: (a.storage.0 & b.storage.0, a.storage.1 & b.storage.1))
    }

    @inlinable public static
    func / (self:Self, bits:UInt8) -> Self
    {
        let mask:Self
        let ones:UInt64 = ~0

        if  bits <= 64
        {
            mask = .init(storage: ((ones << (64 - bits)).bigEndian, 0))
        }
        else
        {
            mask = .init(storage: (ones, (ones << (128 - bits)).bigEndian))
        }

        return self & mask
    }
}
extension IP.V6:RandomAccessCollection
{
    @inlinable public
    var startIndex:Int { 0 }

    @inlinable public
    var endIndex:Int { 8 }

    /// Returns the *i*th word of the address, in **platform** byte order.
    @inlinable public
    subscript(i:Int) -> UInt16
    {
        get
        {
            precondition(self.indices ~= i, "index out of range")

            return withUnsafeBytes(of: self)
            {
                let words:UnsafeBufferPointer<UInt16> = $0.bindMemory(to: UInt16.self)
                return .init(bigEndian: words[i])
            }
        }
        set(word)
        {
            precondition(self.indices ~= i, "index out of range")

            withUnsafeMutableBytes(of: &self)
            {
                let words:UnsafeMutableBufferPointer<UInt16> = $0.bindMemory(to: UInt16.self)
                words[i] = word.bigEndian
            }
        }
    }
}
extension IP.V6:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        self.lazy.map { String.init($0, radix: 16) }.joined(separator: ":")
    }
}
extension IP.V6:LosslessStringConvertible
{
    @inlinable public
    init?(_ string:some StringProtocol)
    {
        self = .zero

        var i:String.Index = string.startIndex
        var z:Int = 0
        for w:Int in 0 ..< 8
        {
            guard
            let j:String.Index = string[i...].firstIndex(of: ":")
            else
            {
                guard w == 7,
                let word:UInt16 = .init(string[i...], radix: 16)
                else
                {
                    return nil
                }

                self[w] = word
                return
            }

            guard i < j
            else
            {
                break
            }

            guard
            let word:UInt16 = .init(string[i ..< j], radix: 16)
            else
            {
                return nil
            }

            self[w] = word
            i = string.index(after: j)
            z = w + 1
        }

        var k:String.Index = string.indices.last ?? i
        for w:Int in (z ..< 8).reversed()
        {
            guard
            let j:String.Index = string[i ... k].lastIndex(of: ":")
            else
            {
                return nil
            }

            guard j < k
            else
            {
                break
            }

            guard
            let word:UInt16 = .init(string[string.index(after: j) ... k], radix: 16)
            else
            {
                return nil
            }

            self[w] = word

            guard i < j
            else
            {
                break
            }

            k = string.index(before: j)
        }
    }
}
